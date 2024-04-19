import UIKit
import Network
import Combine


struct MessagesModel {
    let message:String?
}

enum IPConnectionState:String {
    case connected = "Connected"
    case disconnected = "Disconnected"
}

class TCPnmeaVC: UIViewController {
    
    private var messages = [MessagesModel]()
    private var currentState: IPConnectionState = .disconnected {
        didSet {
            handleConnectionStateChange(currentState)
        }
    }
    private var receiveMessageCancellable: AnyCancellable?
    private var errorMessageCancellable: AnyCancellable?
    private var connectionMessageCancellable: AnyCancellable?
    private var isConnectedCancellable: AnyCancellable?

    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var disconnectedButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var connectionStateLable: UILabel!
    @IBOutlet weak var connectionStateStackView: UIStackView!
    @IBOutlet weak var messageTableVIew: UITableView!{
        didSet {
            messageTableVIew.registerCellFromNib(cellID: "CustomTCPTableView")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleInitialSetup()
        handleBindings()
    }
    
    private func handleBindings() {
        
        receiveMessageCancellable = NetworkManager.shared.$receivedMessage.sink { receivedMessage in
            if let message = receivedMessage {
                print("Received message: \(message)")
                DispatchQueue.main.async {
                    let messageModel = MessagesModel(message: message)
                    self.messages.append(messageModel)
                    self.messageTableVIew.reloadData()
                    self.scrollToBottom(tableView: self.messageTableVIew)
                }
            }
        }
        
        errorMessageCancellable = NetworkManager.shared.$errorMessage.sink { errorMessage in
            if let error = errorMessage {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.showAlert("Information!", error)
                }
            }
        }
        
        isConnectedCancellable = NetworkManager.shared.$isConnected.sink { isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    self.currentState = .connected
                    self.showAlert("Information!", "Connection Successful.")
                }
                else{
                    self.currentState = .disconnected
                }
            }
        }
    }
    
    @IBAction func backDidTapped(_ sender: Any) {
        guard currentState == .disconnected else {
            showAlert("Information!", "Please Disconnect First.")
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func connectDidTapped(_ sender: Any) {
        guard currentState == .disconnected else {
            showAlert("Information!", "Please Disconnect First.")
            return
        }
        
        guard let ip = ipAddressTextField.text, !ip.isEmpty else {
            showAlert("Information!", "Please provide an IP Address.")
            return }
        
        guard let port = portTextField.text, !port.isEmpty,let portUInt16 = UInt16(port) else {
            showAlert("Information!", "Please provide a Port Number.")
            return }
        
        guard isValidIPAddressAndPort(ipAddress: ip, port: port) == true else {
            showAlert("Information!", "Please provide a Valid Port Number and IP Address.")
            return }

        NetworkManager.shared.initilizeSocket(ip, portUInt16)
    }
    
    @IBAction func sendDidTapped(_ sender: Any) {
        guard currentState == .connected else {
            showAlert("Information!", "Please Connect First.")
            return
        }
        
        guard let message = messageTextField.text, !message.isEmpty else {
            showAlert("Information!", "Please enter a message.")
            return
        }
        messages.append( MessagesModel(message: message))
        messageTableVIew.reloadData()
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
        let dataToSend = message.data(using: .utf8)!
        NetworkManager.shared.sendData(dataToSend)
    }
    
    @IBAction func disconnectDidTapped(_ sender: Any) {
        guard currentState == .connected else {
            showAlert("Information!", "Please Connect First.")
            return
        }
        NetworkManager.shared.disconnectSocket()
        self.showAlert("Information!", "Connection disconnected Successfully.")
    }
    
    private func handleInitialSetup() {
        navigationController?.isNavigationBarHidden = true
        currentState = .disconnected
        generateDummyData()
    }
    
    private func scrollToBottom(tableView: UITableView) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
            if indexPath.row >= 0 && indexPath.section >= 0 {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func handleConnectionStateChange(_ currentState: IPConnectionState) {
        switch currentState {
        case .connected:
            connectionStateStackView.backgroundColor = .systemGreen
            connectionStateLable.text = "Connected"
            
        case .disconnected:
            connectionStateStackView.backgroundColor = .red
            connectionStateLable.text = "Disconnected"
        }
    }
    
    private func isValidIPAddressAndPort(ipAddress: String, port: String) -> Bool {
        let ipAddressRegex = #"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"#
        let ipAddressPredicate = NSPredicate(format: "SELF MATCHES %@", ipAddressRegex)
        guard ipAddressPredicate.evaluate(with: ipAddress) else {
            return false
        }
        guard let portNumber = Int(port), portNumber >= 0 && portNumber <= 65535 else {
            return false
        }
        return true
    }
    
    private func generateDummyData() {
        messageTableVIew.reloadData()
        scrollToBottom(tableView: messageTableVIew)
    }
    
    private func showAlert(_ title:String,_ message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        present(alert, animated: true)
    }
}
extension TCPnmeaVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTCPTableView", for: indexPath) as! CustomTCPTableView
        cell.messageLable.text = messages[indexPath.row].message
        return cell
    }
}
