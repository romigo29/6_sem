import os
import pytest
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager


SCREENSHOTS_DIR = "screenshots"
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)


@pytest.fixture
def driver(request):
    options = webdriver.ChromeOptions()
    options.add_argument("--start-maximized")
    options.add_argument("--disable-notifications")
    options.add_argument("--disable-infobars")
    options.add_argument("--lang=en-US")
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option("useAutomationExtension", False)

    driver = webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=options,
    )
    driver.implicitly_wait(5)

    yield driver

    try:
        if hasattr(request.node, "rep_call") and request.node.rep_call.failed:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            name = f"{SCREENSHOTS_DIR}/FAIL_{request.node.name}_{timestamp}.png"
            driver.save_screenshot(name)
            print(f"\n[Screenshot saved] {name}")
    except Exception as e:
        print(f"\n[Screenshot error] {e}")
    finally:
        driver.quit()