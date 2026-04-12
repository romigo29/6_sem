from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from .base_page import BasePage


class HomePage(BasePage):
    CATEGORY_PHONES = (By.XPATH, "//a[normalize-space()='Phones']")
    CATEGORY_LAPTOPS = (By.XPATH, "//a[normalize-space()='Laptops']")
    CATEGORY_MONITORS = (By.XPATH, "//a[normalize-space()='Monitors']")
    PRODUCT_CARDS = (By.CSS_SELECTOR, "#tbodyid .card .hrefch")
    CART_NAV_BTN = (By.ID, "cartur")

    def select_category(self, category_locator):
        # Запоминаем первый товар, чтобы дождаться обновления списка
        old_first = self.find(self.PRODUCT_CARDS).text
        self.click(category_locator)
        self.wait.until(
            lambda d: d.find_element(*self.PRODUCT_CARDS).text != old_first
        )

    def open_product(self, product_name):
        locator = (By.LINK_TEXT, product_name)
        self.wait.until(EC.element_to_be_clickable(locator)).click()

    def go_to_cart(self):
        self.click(self.CART_NAV_BTN)