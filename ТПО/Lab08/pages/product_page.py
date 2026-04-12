from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from .base_page import BasePage


class ProductPage(BasePage):
    PRODUCT_TITLE = (By.CSS_SELECTOR, "h2.name")
    PRODUCT_PRICE = (By.CSS_SELECTOR, "h3.price-container")
    ADD_TO_CART_BTN = (By.XPATH, "//a[normalize-space()='Add to cart']")
    HOME_NAV_BTN = (By.CSS_SELECTOR, "a.nav-link[href='index.html']")

    def get_title(self):
        return self.get_text(self.PRODUCT_TITLE)

    def add_to_cart(self):
        self.wait.until(EC.element_to_be_clickable(self.ADD_TO_CART_BTN)).click()
        alert_text = self.get_alert_text_and_accept()
        self.wait_for_ajax()
        return alert_text

    def go_home(self):
        self.driver.get(self.BASE_URL)