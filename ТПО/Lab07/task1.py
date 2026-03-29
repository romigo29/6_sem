import time

from selenium import webdriver
from selenium.webdriver.common.by import By

driver = webdriver.Chrome()


driver.get("https://minsktrans.by/")

# Task 1
print("Search result by ID: ", driver.find_element(By.ID, "secondary"))

print("Search result by Name: ", driver.find_element(By.NAME, "description"))

print("Search result 1 by CSS:", driver.find_elements(By.CSS_SELECTOR, "footer a[href]"))
print("Search result 2 by CSS:", driver.find_elements(By.CSS_SELECTOR, "div.footer_box ul.footer_menu"))

print("Search result by partial line text:", driver.find_elements(By.PARTIAL_LINK_TEXT, "Подробнее"))

print("Search result by XPATH:", driver.find_elements(By.XPATH, "//a[@href='#' and @class='menu-mobile']"))
print("Search result by XPATH:", driver.find_elements(By.XPATH, "//ul[@class='sub-menu']/li/a"))

print("Search multiple elements:", driver.find_elements("class name", "sub-menu"))

