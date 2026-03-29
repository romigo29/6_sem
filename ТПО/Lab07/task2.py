from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

driver = webdriver.Chrome()
driver.implicitly_wait(5)
driver.maximize_window()
wait = WebDriverWait(driver, 10)


def hide_ads():
    driver.execute_script("""
        document.querySelectorAll('#adplus-anchor, #fixedban, footer, iframe[id*="google"]')
            .forEach(el => el.remove());
    """)


# ТЕСТ 1: Авторизация
print("=" * 50)
print("ТЕСТ 1: Заполнение формы (авторизация)")
print("=" * 50)

driver.get("https://demoqa.com/automation-practice-form")
time.sleep(3)
hide_ads()

driver.find_element(By.ID, "firstName").send_keys("Игорь")
driver.find_element(By.ID, "lastName").send_keys("Романов")
driver.find_element(By.ID, "userEmail").send_keys("igor@test.com")
driver.find_element(By.CSS_SELECTOR, "label[for='gender-radio-1']").click()
driver.find_element(By.ID, "userNumber").send_keys("1234567890")

submit = driver.find_element(By.ID, "submit")
driver.execute_script("arguments[0].scrollIntoView(true);", submit)
time.sleep(1)
driver.execute_script("arguments[0].click();", submit)

modal = wait.until(EC.visibility_of_element_located(
    (By.ID, "example-modal-sizes-title-lg")
))

assert "Thanks" in modal.text, f"Ожидали 'Thanks', получили '{modal.text}'"
print(f"[PASSED] Модальное окно: '{modal.text}'")

table_text = driver.find_element(By.CSS_SELECTOR, "table.table tbody").text
assert "Игорь" in table_text, "Имя не найдено"
print("[PASSED] Имя 'Игорь' найдено в результатах")

driver.find_element(By.ID, "closeLargeModal").click()
time.sleep(1)
print()


# ТЕСТ 2: Text Box
print("=" * 50)
print("ТЕСТ 2: Text Box — ввод и проверка данных")
print("=" * 50)

driver.get("https://demoqa.com/text-box")
time.sleep(3)
hide_ads()

driver.find_element(By.ID, "userName").send_keys("Тестовый Пользователь")
driver.find_element(By.ID, "userEmail").send_keys("test@example.com")
driver.find_element(By.ID, "currentAddress").send_keys("ул.Свердловая, д. 19")
driver.find_element(By.ID, "permanentAddress").send_keys("ул. Белорусская, д. 21")

submit = driver.find_element(By.ID, "submit")
driver.execute_script("arguments[0].scrollIntoView(true);", submit)
time.sleep(1)
driver.execute_script("arguments[0].click();", submit)

output = wait.until(EC.visibility_of_element_located((By.ID, "output")))
output_text = output.text

assert "Тестовый Пользователь" in output_text, "Имя не найдено"
assert "test@example.com" in output_text, "Email не найден"
print("[PASSED] Имя найдено в результатах")
print("[PASSED] Email найден в результатах")
print()


# ТЕСТ 3: форма
print("=" * 50)
print("ТЕСТ 3: Check Box (хобби на practice-form)")
print("=" * 50)

driver.get("https://demoqa.com/automation-practice-form")
time.sleep(3)
hide_ads()

driver.find_element(By.ID, "firstName").send_keys("Тест")
driver.find_element(By.ID, "lastName").send_keys("Чекбокс")
driver.find_element(By.CSS_SELECTOR, "label[for='gender-radio-2']").click()
driver.find_element(By.ID, "userNumber").send_keys("9876543210")

driver.find_element(By.CSS_SELECTOR, "label[for='hobbies-checkbox-1']").click()  # Sports
driver.find_element(By.CSS_SELECTOR, "label[for='hobbies-checkbox-3']").click()  # Music
time.sleep(1)

sports_cb = driver.find_element(By.ID, "hobbies-checkbox-1")
music_cb = driver.find_element(By.ID, "hobbies-checkbox-3")

assert sports_cb.is_selected(), "Чекбокс Sports не выбран"
assert music_cb.is_selected(), "Чекбокс Music не выбран"
print("[PASSED] Чекбокс 'Sports' выбран")
print("[PASSED] Чекбокс 'Music' выбран")

submit = driver.find_element(By.ID, "submit")
driver.execute_script("arguments[0].scrollIntoView(true);", submit)
time.sleep(1)
driver.execute_script("arguments[0].click();", submit)

modal = wait.until(EC.visibility_of_element_located(
    (By.ID, "example-modal-sizes-title-lg")
))
table_text = driver.find_element(By.CSS_SELECTOR, "table.table tbody").text

assert "Sports" in table_text, "Sports не найден в результатах"
assert "Music" in table_text, "Music не найден в результатах"
print("[PASSED] Sports и Music есть в результатах формы")

driver.find_element(By.ID, "closeLargeModal").click()
time.sleep(1)
print()


# ТЕСТ 4: Сквозной тест
print("=" * 50)
print("ТЕСТ 4: Сквозной — главная -> Elements -> Text Box -> проверка")
print("=" * 50)

# главная
driver.get("https://demoqa.com/")
time.sleep(3)
hide_ads()

# клик по Elements
card = driver.find_element(By.XPATH, "//h5[text()='Elements']")
driver.execute_script("arguments[0].click();", card)
time.sleep(2)
hide_ads()

# клик по Text Box
item = wait.until(EC.element_to_be_clickable(
    (By.XPATH, "//span[text()='Text Box']")
))
item.click()
time.sleep(1)

# заполняем
driver.find_element(By.ID, "userName").send_keys("Сквозной Тест")
driver.find_element(By.ID, "userEmail").send_keys("through@test.com")

# отправляем
submit = driver.find_element(By.ID, "submit")
driver.execute_script("arguments[0].scrollIntoView(true);", submit)
time.sleep(1)
driver.execute_script("arguments[0].click();", submit)

# проверяем
output = wait.until(EC.visibility_of_element_located((By.ID, "output")))
name_result = driver.find_element(By.ID, "name").text
email_result = driver.find_element(By.ID, "email").text

assert "Сквозной Тест" in name_result, f"Имя не совпало: {name_result}"
assert "through@test.com" in email_result, f"Email не совпал: {email_result}"
print(f"[PASSED] Имя: {name_result}")
print(f"[PASSED] Email: {email_result}")
print()


# Radio Button
print("=" * 50)
print("ТЕСТ 5: Radio Button")
print("=" * 50)

driver.get("https://demoqa.com/radio-button")
time.sleep(3)
hide_ads()

driver.find_element(By.CSS_SELECTOR, "label[for='impressiveRadio']").click()
time.sleep(1)

result = wait.until(EC.visibility_of_element_located(
    (By.CSS_SELECTOR, "p.mt-3")
))

assert "Impressive" in result.text, f"Ожидали 'Impressive', получили '{result.text}'"
print(f"[PASSED] Radio button: '{result.text}'")
print()


# ==================== ИТОГ ====================
print("=" * 50)
print("ВСЕ 5 ТЕСТОВ ПРОЙДЕНЫ!")
print("=" * 50)

time.sleep(3)
driver.quit()