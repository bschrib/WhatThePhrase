import os
import json
import requests
import sys

categories = {
    "Geography": "country",
    "Transportation": "vehicle",
    "Around The House": "furniture",
    "Food/Drink": "food",
    "Plants/Animals": "animal",
    "Family": "family",
    "Everything": "random",
    "Tech/Inventions": "invention",
    "History Buff": "history",
    "Entertainment": "entertainment",
    "Sports/Games": "sport"
}

def fetch_words_for_category(keyword, num_words):
    url = f"https://api.datamuse.com/words?ml={keyword}&max={num_words}"
    response = requests.get(url)
    response.raise_for_status()
    words = [item['word'] for item in response.json()]
    return words

def main(num_words):
    wordlists = {}
    
    for category, keyword in categories.items():
        print(f"Fetching words for category '{category}'")
        words = fetch_words_for_category(keyword, num_words)
        wordlists[category] = words

    output_file_path = "../WordLists/wordlists.json"
    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

    with open(output_file_path, "w") as output_file:
        json.dump(wordlists, output_file, indent=2)

    print("Wordlists generated and saved.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        num_words = int(sys.argv[1])
    else:
        num_words = 100

    main(num_words)
