import XCTest

final class CineScopeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITestMock", "-UITestReset"]
        app.launch()
    }

    func testDiscoverShowsMovies() {
        XCTAssertTrue(app.collectionViews["movie-grid"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.cells["movie-cell-1"].exists)
        XCTAssertTrue(app.searchFields["Search movies"].exists)
    }

    func testOpenDetailAndSave() {
        XCTAssertTrue(app.cells["movie-cell-1"].waitForExistence(timeout: 5))
        app.cells["movie-cell-1"].tap()
        XCTAssertTrue(app.buttons["watchlist-button"].waitForExistence(timeout: 5))
        app.buttons["watchlist-button"].tap()
        XCTAssertTrue(app.buttons["Saved to Watchlist"].exists)
    }

    func testWatchlistTabExists() {
        XCTAssertTrue(app.buttons["Watchlist"].exists)
        app.buttons["Watchlist"].tap()
        XCTAssertTrue(app.tables["watchlist-table"].exists)
    }
}
