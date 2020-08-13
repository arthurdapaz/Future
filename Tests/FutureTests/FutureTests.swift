import XCTest
@testable import Future

final class FutureTests: XCTestCase {
    
    func testFutureOperation() {
        let futureOperation: Future<Bool, Error> = Future { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                operation(.success(true))
            }
        }
        
        future {
            futureOperation
        }.success { answer in
            XCTAssertTrue(answer)
        }.always { answer in
            XCTAssertNoThrow({ try answer.get() })
        }
    }
    
    func testFutureFailure() {
        let futureError: Future<Any, Error> = Future(error: NSError(domain: "Falha", code: 0, userInfo: nil))
        
        future {
            futureError
        }.failure { error in
            XCTAssertTrue(error.localizedDescription.contains("Falha"))
        }
    }
    
    func testFutureSuccess() {
        let futureBasic: Future<String, Error> = Future(value: "Sucesso")
        
        future {
            futureBasic
        }.success {
            XCTAssertTrue($0 == "Sucesso")
        }
    }
    
    func extrairZip(entry: Bool) -> Future<String, Error> {
        Future { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                operation(.success("Válido"))
            }
        }
    }
    
    func testThen() {
        let futureOperation: Future<Bool, Error> = Future { operation in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                operation(.success(true))
            }
        }
        

        future {
            futureOperation
        }
        .then(extrairZip(entry:))
        .always { resultado in
            
            XCTAssertNoThrow({ try resultado.get() })
            XCTAssertTrue((try! resultado.get()) == "a")
        }
        
    }

    static var allTests = [
        ("testFutureOperation", testFutureOperation),
        ("testFutureFailure", testFutureFailure),
        ("andThen", testThen)
    ]
    
}
