from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoAlertPresentException


class BasePage:
    BASE_URL = "https://www.demoblaze.com/index.html"

    def __init__(self, driver, timeout=10):
        self.driver = driver
        self.wait = WebDriverWait(driver, timeout)

    def open(self, url=None):
        self.driver.get(url or self.BASE_URL)

    def find(self, locator):
        return self.wait.until(EC.presence_of_element_located(locator))

    def click(self, locator):
        self.wait.until(EC.element_to_be_clickable(locator)).click()

    def type(self, locator, text):
        element = self.find(locator)
        element.clear()
        element.send_keys(text)

    def is_visible(self, locator, timeout=10):
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.visibility_of_element_located(locator)
            )
            return True
        except TimeoutException:
            return False

    def get_text(self, locator):
        return self.find(locator).text

    def get_alert_text_and_accept(self, timeout=5):
        try:
            alert = WebDriverWait(self.driver, timeout).until(EC.alert_is_present())
            text = alert.text
            alert.accept()
            return text
        except (TimeoutException, NoAlertPresentException):
            return None

    def wait_for_ajax(self, timeout=10):
        from selenium.webdriver.support.ui import WebDriverWait
        try:
            WebDriverWait(self.driver, timeout).until(
                lambda d: d.execute_script("return jQuery.active == 0")
            )
        except Exception:
            pass  # jQuery может быть не загружен – не падаем