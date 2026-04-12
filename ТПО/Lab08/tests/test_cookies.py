import json
import os
import pytest
from pages.login_page import LoginPage

VALID_USER = "pigeon99905"
VALID_PASSWORD = "qwerty123"
COOKIES_FILE = "cookies.json"


@pytest.mark.cookies
class TestCookies:

    def test_print_all_cookies(self, driver):
        page = LoginPage(driver)
        page.open()
        page.login(VALID_USER, VALID_PASSWORD)

        cookies = driver.get_cookies()
        print(f"\nНайдено куков: {len(cookies)}")
        for c in cookies:
            print(f"  {c['name']} = {c['value']}")

        with open(COOKIES_FILE, "w", encoding="utf-8") as f:
            json.dump(cookies, f, indent=2, ensure_ascii=False)

        driver.save_screenshot("screenshots/all_cookies.png")

        assert any(c["name"] == "user" for c in cookies), \
            "Cookie авторизации 'user' не найдена"

