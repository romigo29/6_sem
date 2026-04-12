import pytest
from pages.home_page import HomePage
from pages.product_page import ProductPage
from pages.cart_page import CartPage

@pytest.mark.cart
class TestCart:

    def test_add_single_product_to_cart(self, driver):
        home = HomePage(driver)
        home.open()
        home.open_product("Samsung galaxy s6")

        product = ProductPage(driver)
        assert product.get_title() == "Samsung galaxy s6"

        alert = product.add_to_cart()
        assert alert == "Product added"

        product.go_home()
        home.go_to_cart()

        cart = CartPage(driver)
        cart.wait_for_rows()

        driver.save_screenshot("screenshots/add_single_product_to_cart_success.png")

        assert "Samsung galaxy s6" in cart.get_item_titles()
        assert cart.get_items_count() == 1

    def test_add_multiple_products_to_cart(self, driver):
        home = HomePage(driver)
        home.open()

        products_to_add = ["Nokia lumia 1520", "Nexus 6"]

        for name in products_to_add:
            home.open_product(name)
            product = ProductPage(driver)
            assert product.add_to_cart() == "Product added"
            product.go_home()

        home.go_to_cart()
        cart = CartPage(driver)
        cart.wait_for_rows()

        driver.save_screenshot("screenshots/add_multiple_products_to_cart_success.png")

        titles = cart.get_item_titles()
        assert cart.get_items_count() == 2
        for name in products_to_add:
            assert name in titles

    def test_cart_total_price_is_sum_of_items(self, driver):
        home = HomePage(driver)
        home.open()

        expected_total = 0
        for name in ["Nokia lumia 1520", "Nexus 6"]:
            home.open_product(name)
            product = ProductPage(driver)
            # Вытаскиваем цену до добавления
            price_text = product.get_text(ProductPage.PRODUCT_PRICE)
            # Формат: "$820 *includes tax"
            price = int(price_text.replace("$", "").split("*")[0].strip())
            expected_total += price
            product.add_to_cart()
            product.go_home()

        home.go_to_cart()
        cart = CartPage(driver)
        cart.wait_for_rows()

        driver.save_screenshot("screenshots/total_price.png")

        assert cart.get_total() == expected_total