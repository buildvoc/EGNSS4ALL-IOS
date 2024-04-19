import Foundation
import Network
import Combine
import CocoaAsyncSocket

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    public var socket: GCDAsyncSocket?
    private var mutableData: NSMutableData!
    
    @Published var errorMessage: String?
    @Published var receivedMessage: String?
    @Published var connectionMessage: String?
    @Published var isConnected: Bool = false
    
    private var currentIP:String?
    private var currentPort:UInt16?
    
    
    public func initilizeSocket(_ ipAddress:String,_ port:UInt16) {
        currentIP = ipAddress
        currentPort = port
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try socket?.connect(toHost: ipAddress, onPort: port)
            isConnected = true
        } catch {
            isConnected = false
        }
    }
    
    public func disconnectSocket() {
        socket?.disconnect()
    }
    
    public func sendData(_ data:Data) {
        mutableData = NSMutableData.init(data: data)
        mutableData.append(GCDAsyncSocket.crlfData())
        socket?.write(mutableData as Data, withTimeout: -1, tag: 0)
    }
}
extension NetworkManager: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        isConnected = true
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let message = String(data: data as Data, encoding: String.Encoding.utf8)
        receivedMessage = message
        socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        isConnected = false
    }
}
