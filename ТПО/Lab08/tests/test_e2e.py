import pytest
from pages.login_page import LoginPage
from pages.home_page import HomePage
from pages.product_page import ProductPage
from pages.cart_page import CartPage

VALID_USER = "pigeon99905"
VALID_PASSWORD = "qwerty123"

@pytest.mark.e2e
@pytest.mark.regression
class TestEndToEnd:

    def test_full_purchase_flow(self, driver):
        # 1. Логин
        login_page = LoginPage(driver)
        login_page.open()
        login_page.login(VALID_USER, VALID_PASSWORD)
        assert login_page.get_welcome_text() == f"Welcome {VALID_USER}"

        # 2. Выбор категории Laptops
        home = HomePage(driver)
        home.select_category(HomePage.CATEGORY_LAPTOPS)

        # 3. Открываем ноутбук и добавляем в корзину
        home.open_product("Sony vaio i5")
        product = ProductPage(driver)
        assert product.get_title() == "Sony vaio i5"

        price_text = product.get_text(ProductPage.PRODUCT_PRICE)
        expected_price = int(price_text.replace("$", "").split("*")[0].strip())

        assert product.add_to_cart() == "Product added."
        product.go_home()

        # 4. Переход в корзину и проверка содержимого
        home.go_to_cart()
        cart = CartPage(driver)
        cart.wait_for_rows()

        titles = cart.get_item_titles()
        assert "Sony vaio i5" in titles, \
            f"Sony vaio i5 не найден в корзине. Содержимое: {titles}"

        # 5. Оформление заказа
        cart.place_order(
            name="Igor Test",
            country="Ukraine",
            city="Kyiv",
            card="4111111111111111",
            month="12",
            year="2027",
        )

        # 6. Проверка подтверждения
        confirmation = cart.get_confirmation_text()
        assert confirmation == "Thank you for your purchase!"
        cart.confirm_order()