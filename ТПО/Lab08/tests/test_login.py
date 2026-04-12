import pytest
from pages.login_page import LoginPage

VALID_USER = "pigeon99905"
VALID_PASSWORD = "qwerty123"

@pytest.mark.login
class TestLogin:

    @pytest.mark.smoke
    def test_login_with_valid_credentials(self, driver):
        page = LoginPage(driver)
        page.open()
        page.login(VALID_USER, VALID_PASSWORD)

        welcome = page.get_welcome_text()
        driver.save_screenshot("screenshots/login_success.png")

        assert welcome == f"Welcome {VALID_USER}", \
            f"Ожидалось 'Welcome {VALID_USER}', получено '{welcome}'"
        assert page.is_logged_in()


    @pytest.mark.skip(reason="Функция 'Forgot password' пока не реализована на demoblaze")
    def test_forgot_password(self, driver):
        pass

    @pytest.mark.regression
    @pytest.mark.parametrize(
        "username,password,expected_alert",
        [
            ("", "", "Please fill out Username and Password."),
            ("nonexistent_xyz_999", "any", "User does not exist."),
            (VALID_USER, "wrong_password", "Wrong password."),
            ("   ", "   ", "Wrong password."),  # ← demoblaze принимает пробелы как валидное имя
        ],
        ids=["empty_fields", "wrong_user", "wrong_password", "whitespace_only"],
    )


    def test_login_negative_cases(self, driver, username, password, expected_alert):
        page = LoginPage(driver)
        page.open()
        page.login(username, password)

        alert_text = page.get_alert_text_and_accept()
        assert alert_text == expected_alert