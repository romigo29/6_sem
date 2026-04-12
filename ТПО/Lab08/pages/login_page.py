from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from .base_page import BasePage


class LoginPage(BasePage):
    # Локаторы
    LOGIN_NAV_BTN = (By.ID, "login2")
    USERNAME_INPUT = (By.ID, "loginusername")
    PASSWORD_INPUT = (By.ID, "loginpassword")
    SUBMIT_BTN = (By.XPATH, "//button[@onclick='logIn()']")
    LOGIN_MODAL = (By.ID, "logInModal")
    WELCOME_LABEL = (By.ID, "nameofuser")
    LOGOUT_BTN = (By.ID, "logout2")

    def open_login_modal(self):
        self.click(self.LOGIN_NAV_BTN)
        self.wait.until(EC.visibility_of_element_located(self.USERNAME_INPUT))

    def login(self, username, password):
        self.open_login_modal()
        self.type(self.USERNAME_INPUT, username)
        self.type(self.PASSWORD_INPUT, password)
        self.click(self.SUBMIT_BTN)

    def get_welcome_text(self, timeout=10):
        self.wait.until(EC.visibility_of_element_located(self.WELCOME_LABEL))
        return self.get_text(self.WELCOME_LABEL)

    def is_logged_in(self):
        return self.is_visible(self.WELCOME_LABEL) and self.is_visible(self.LOGOUT_BTN)