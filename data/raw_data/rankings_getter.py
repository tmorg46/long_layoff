from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
import pandas as pd
import time

#############
# modify the three lines below and let 'er rip

years = list(range(2015,2026))

#############

# Main function
def main():

    data = []

    for year in years:
        # Set up the Selenium webdriver
        driver = webdriver.Firefox()

        season_url = f"https://roadtonationals.com/results/standings/season"

        driver.get(season_url)
        time.sleep(4)

        # Find the year dropdown using its id 'year_filter'
        year_dropdown = Select(driver.find_element(By.ID, "year_filter"))

        # Select the desired year
        year_dropdown.select_by_value(str(year))

        # Wait for the page to update/navigate after the selection
        time.sleep(4)

        # Locate table headers
        headers = [header.text for header in driver.find_elements(By.CSS_SELECTOR, ".rt-th .rt-resizable-header-content") if header.text]
        headers = headers[:2]

        # Locate table rows
        rows = driver.find_elements(By.CSS_SELECTOR, ".rt-tr-group")

        for row in rows:
            # Grab only the first two cells from each row
            cells = row.find_elements(By.CSS_SELECTOR, ".rt-td")
            row_data = [cell.text for cell in cells[:5]]
            if row_data:
                # Add the year as the first column
                data.append([year] + row_data)

        driver.quit()

        print(f"scraped for {year}")

    df = pd.DataFrame(data, columns=["year", "nqs_rank", "team", "nqs", "avg", "high"])

    scrape = "C:/Users/toom/Desktop/rankscrapes.csv"
    df.to_csv(scrape, index=False, encoding="utf-8")

    print("mission accomplished!!")


if __name__ == "__main__":
    main()

