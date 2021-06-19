import XCTest
import RxSwift
import RxBlocking
@testable import Solana

class serializeAndSendWithFee: XCTestCase {
    var endpoint = RPCEndpoint.devnetSolana
    var solanaSDK: Solana!
    var account: Account { solanaSDK.accountStorage.account! }

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        solanaSDK = Solana(router: NetworkingRouter(endpoint: endpoint), accountStorage: InMemoryAccountStorage())
        let account = Account(phrase: wallet.testAccount.components(separatedBy: " "), network: endpoint.network)!
        try solanaSDK.accountStorage.save(account)
    }

    func testSimulationSerializeAndSend() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let instruction = SystemProgram.transferInstruction(
            from: account.publicKey,
            to: PublicKey(string: toPublicKey)!,
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try! solanaSDK.serializeAndSendWithFeeSimulation(instructions: [instruction], signers: [account]).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    
    func testSerializeAndSend() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! solanaSDK.getBalance().toBlocking().first()
        XCTAssertNotNil(balance)

        let instruction = SystemProgram.transferInstruction(
            from: account.publicKey,
            to: PublicKey(string: toPublicKey)!,
            lamports: 0.001.toLamport(decimals: 9)
        )
        
        let transactionId = try! solanaSDK.serializeAndSendWithFee( instructions: [instruction], signers: [account]).toBlocking().first()
        XCTAssertNotNil(transactionId)
    }
    
    func testTransferInstruction() {
        let fromPublicKey = PublicKey(string: "QqCCvshxtqMAL2CVALqiJB7uEeE5mjSPsseQdDzsRUo")!
        let toPublicKey = PublicKey(string: "GrDMoeqMLFjeXQ24H56S1RLgT4R76jsuWCd6SvXyGPQ5")!
        
        let instruction = SystemProgram.transferInstruction(from: fromPublicKey, to: toPublicKey, lamports: 3000)
        
        XCTAssertEqual(PublicKey.programId, instruction.programId)
        XCTAssertEqual(2, instruction.keys.count)
        XCTAssertEqual(toPublicKey, instruction.keys[1].publicKey)
        XCTAssertEqual([2, 0, 0, 0, 184, 11, 0, 0, 0, 0, 0, 0], instruction.data)
    }
    
    func testInitializeAccountInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.initializeAccountInstruction(account: publicKey, mint: publicKey, owner: publicKey)
        XCTAssertEqual("2", Base58.encode(instruction.data))
    }
    
    func testApproveInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.approveInstruction(tokenProgramId: publicKey, account: publicKey, delegate: publicKey, owner: publicKey, amount: 1000)
        XCTAssertEqual("4d5tSvUuzUVM", Base58.encode(instruction.data))
    }
}
