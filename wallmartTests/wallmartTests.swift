//
//  wallmartTests.swift
//  wallmartTests
//
//  Created by Aravind Bilugu on 2/27/25.
//


import XCTest
@testable import wallmart

class wallmartTests: XCTestCase {
   var viewController: ViewController!
   var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        viewController = ViewController()
        mockURLSession = MockURLSession()
        viewController.urlSession = mockURLSession
        viewController.countries = []
        
        // Manually create the views since there's no Storyboard
        let tableView = UITableView()
        let searchBar = UISearchBar()
        
        // Assign them to the ViewController's properties
        viewController.tableView = tableView
        viewController.searchBar = searchBar
        
        // Add views to the ViewController's view hierarchy
        viewController.view = UIView()
        viewController.view.addSubview(searchBar)
        viewController.view.addSubview(tableView)
        
        // Set up data source and delegate
        viewController.tableView.dataSource = viewController
        viewController.tableView.delegate = viewController
        viewController.searchBar.delegate = viewController
        
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        mockURLSession = nil
        super.tearDown()
    }

    func testFetchCountries_Success() {
        let jsonString = """
        [
            { "name": "United States", "region": "Americas", "code": "US", "capital": "Washington D.C." },
            { "name": "Canada", "region": "Americas", "code": "CA", "capital": "Ottawa" }
        ]
        """
        let data = jsonString.data(using: .utf8)
        mockURLSession.nextData = data

        let expectation = self.expectation(description: "Countries fetched and table reloaded")
        viewController.fetchCountries()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewController.countries.count, 2)
            if !self.viewController.countries.isEmpty {
                XCTAssertEqual(self.viewController.countries[0].name, "United States")
                XCTAssertEqual(self.viewController.countries[0].region, "Americas")
                XCTAssertEqual(self.viewController.countries[0].code, "US")
                XCTAssertEqual(self.viewController.countries[0].capital, "Washington D.C.")
                XCTAssertEqual(self.viewController.countries[1].name, "Canada")
                XCTAssertEqual(self.viewController.countries[1].region, "Americas")
                XCTAssertEqual(self.viewController.countries[1].code, "CA")
                XCTAssertEqual(self.viewController.countries[1].capital, "Ottawa")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testFetchCountries_Failure() {
        mockURLSession.nextError = NSError(domain: "TestError", code: 1, userInfo: nil)

        let expectation = self.expectation(description: "Handle error gracefully")
        viewController.fetchCountries()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.viewController.countries.isEmpty)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
}



class MockURLSession: URLSession {
    var nextData: Data?
    var nextError: Error?

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSessionDataTask()
        task.completionHandler = {
            completionHandler(self.nextData, nil, self.nextError)
        }
        return task
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: (() -> Void)?

    override func resume() {
        completionHandler?()
    }
}
