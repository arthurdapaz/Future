import XCTest
@testable import Future

final class FutureTests: XCTestCase {
    
    func testFutureOperation() {
        let exp = expectation(description: "Return true")
        exp.assertForOverFulfill = false
        
        let futureOperation: Future<Bool, Error> = Future { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                operation(.success(true))
            }
        }
        
        futureOperation
            .success { answer in
                XCTAssertTrue(answer)
                exp.fulfill()
            }
            .always { answer in
                XCTAssertNoThrow({ try answer.get() })
                exp.fulfill()
            }
            .invoke()
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func testFutureFailure() {
        let futureError: Future<Any, Error> = Future(error: NSError(domain: "Falha", code: 0, userInfo: nil))
        
        
        futureError
            .failure { error in
                XCTAssertTrue(error.localizedDescription.contains("Falha"))
            }
            .invoke()
    }
    
    func testFutureSuccess() {
        let futureBasic: Future<String, Error> = Future(value: "Sucesso")
        
        futureBasic
            .success {
                XCTAssertTrue($0 == "Sucesso")
            }
            .invoke()
    }
    
    func testThen() {
        let futureOperation: Future<Bool, Error> = Future { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                operation(.success(true))
            }
        }
        
        futureOperation
            .then(extrairZip(entry:))
            .always { resultado in
                
                XCTAssertNoThrow({ try resultado.get() })
                XCTAssertTrue((try! resultado.get()) == "a")
            }.invoke()
    }
    
    private func extrairZip(entry: Bool) -> Future<String, Error> {
        Future { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                operation(.success("Válido"))
            }
        }
    }

    static var allTests = [
        ("testFutureOperation", testFutureOperation),
        ("testFutureFailure", testFutureFailure),
        ("testFutureSuccess", testFutureSuccess),
        ("testThen", testThen)
    ]
    
}
