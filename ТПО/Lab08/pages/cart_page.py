from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from .base_page import BasePage
import time


class CartPage(BasePage):
    CART_URL = "https://www.demoblaze.com/cart.html"
    CART_ROWS = (By.CSS_SELECTOR, "#tbodyid tr")
    CART_ITEM_TITLES = (By.CSS_SELECTOR, "#tbodyid tr td:nth-child(2)")
    CART_ITEM_PRICES = (By.CSS_SELECTOR, "#tbodyid tr td:nth-child(3)")
    TOTAL_PRICE = (By.ID, "totalp")
    PLACE_ORDER_BTN = (By.XPATH, "//button[normalize-space()='Place Order']")
    DELETE_LINK = (By.XPATH, "//a[normalize-space()='Delete']")

    # Модалка оформления заказа
    ORDER_MODAL = (By.ID, "orderModal")
    NAME_INPUT = (By.ID, "name")
    COUNTRY_INPUT = (By.ID, "country")
    CITY_INPUT = (By.ID, "city")
    CARD_INPUT = (By.ID, "card")
    MONTH_INPUT = (By.ID, "month")
    YEAR_INPUT = (By.ID, "year")
    PURCHASE_BTN = (By.XPATH, "//button[normalize-space()='Purchase']")
    CONFIRM_OK_BTN = (By.XPATH, "//button[normalize-space()='OK']")
    CONFIRM_MESSAGE = (By.CSS_SELECTOR, ".sweet-alert h2")

    def open(self):
        super().open(self.CART_URL)
        self.wait_for_rows()

    def wait_for_rows(self, timeout=10):
        self.wait.until(
            lambda d: len(d.find_elements(*self.CART_ROWS)) > 0
        )

    def get_item_titles(self):
        self.wait_for_rows()
        return [el.text for el in self.driver.find_elements(*self.CART_ITEM_TITLES)]

    def get_items_count(self):
        return len(self.driver.find_elements(*self.CART_ROWS))

    def get_total(self):
        text = self.find(self.TOTAL_PRICE).text
        return int(text) if text.strip() else 0

    def place_order(self, name, country, city, card, month, year):
        self.click(self.PLACE_ORDER_BTN)
        self.wait.until(EC.visibility_of_element_located(self.NAME_INPUT))
        self.type(self.NAME_INPUT, name)
        self.type(self.COUNTRY_INPUT, country)
        self.type(self.CITY_INPUT, city)
        self.type(self.CARD_INPUT, card)
        self.type(self.MONTH_INPUT, month)
        self.type(self.YEAR_INPUT, year)
        self.click(self.PURCHASE_BTN)

    def get_confirmation_text(self):
        return self.wait.until(
            EC.visibility_of_element_located(self.CONFIRM_MESSAGE)
        ).text

    def confirm_order(self):
        self.click(self.CONFIRM_OK_BTN)

    def wait_for_items_count(self, expected_count, timeout=15):

        end_time = time.time() + timeout
        while time.time() < end_time:
            rows = self.driver.find_elements(*self.CART_ROWS)
            if len(rows) >= expected_count:
                return
            time.sleep(0.5)
            self.driver.refresh()
        raise TimeoutError(
            f"Ожидалось {expected_count} товаров, найдено {len(rows)}"
        )
