
import pandas as pd
import re

# Load dataset
df = pd.read_csv("rotten_tomatoes_critic_reviews.csv")

# Print available columns for debugging
print("Available Columns:", df.columns)

# Select relevant columns (update these to match your dataset)
selected_columns = ["critic_name", "review_content", "review_score", "review_type"]
df = df[selected_columns]

# Function to clean text
def clean_text(text):
    if isinstance(text, str):  # Ensure it's a string
        text = re.sub(r"<.*?>", "", text)  # Remove HTML tags
        text = re.sub(r"[^a-zA-Z0-9 ]", "", text)  # Remove special characters
        text = text.lower().strip()  # Convert to lowercase
    return text

# Apply cleaning function to review content
df["review_content"] = df["review_content"].apply(clean_text)

# Drop rows with missing values
df.dropna(inplace=True)

# Save cleaned data
df.to_csv("cleaned_reviews.csv", index=False)

print("✅ Data cleaning complete! Saved as cleaned_reviews.csv")

