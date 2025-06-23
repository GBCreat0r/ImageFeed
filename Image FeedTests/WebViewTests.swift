//
//  WebViewTests.swift
//  Image FeedTests
//
//  Created by semrumyantsev on 26.05.2025.
//


@testable import Image_Feed
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let webViewController = WebViewViewController()

        let mockPresenter = MockWebViewPresenter()

        webViewController.presenter = mockPresenter
        //when
        _ = webViewController.view

        XCTAssertTrue(mockPresenter.viewDidLoadCalled, "viewDidLoad презентера не был вызван")
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewControllerSpy = WebViewViewControllerSpy()

        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        //when
        presenter.view = viewControllerSpy
        viewControllerSpy.presenter = presenter

        presenter.viewDidLoad()
        //then
        XCTAssertTrue(viewControllerSpy.loadRequestCalled, "Метод load(request:) вьюконтроллера не был вызван")
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        //when
        let url = authHelper.authURL()
        guard let url else {
            XCTFail("Авторизационная ссылка собрана неверно")
            return
        }
        let urlString = url.absoluteString
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        //when
        let code = authHelper.code(from: url)
        //then
        XCTAssertEqual(code, "test code")
    }
}

class MockWebViewPresenter: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}

    func code(from url: URL) -> String? {
        return nil
    }
}

class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var loadRequestCalled = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}
