#!/bin/bash

# Input and output file names
INPUT_FILE="input.csv"
OUTPUT_FILE="unique_entries.csv"
EMAIL_TO="recipient@example.com"
EMAIL_SUBJECT="Unique CSV Entries"
EMAIL_BODY_TEMPLATE="email_template.html"
EMAIL_BODY="email_body.html"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

# Remove duplicates based on all columns, handling inconsistent spacing and missing values
awk -F',' 'NR==1 {print; next} {
    key="";
    for(i=1; i<=NF; i++) key = key sprintf("%s|", $i);
    gsub(/^[ \t]+|[ \t]+$/, "", key); # Trim spaces
    if(!seen[key]++) print;
}' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Unique entries saved to '$OUTPUT_FILE'"

# Check if email template exists, otherwise use default content
if [ -f "$EMAIL_BODY_TEMPLATE" ]; then
    cp "$EMAIL_BODY_TEMPLATE" "$EMAIL_BODY"
else
    echo "<html><body><h2>Here is your unique CSV file</h2><p>Please find the attached file.</p></body></html>" > "$EMAIL_BODY"
fi

# Send email with attachment
sendmail -t <<EOF
To: $EMAIL_TO
Subject: $EMAIL_SUBJECT
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="boundary"

--boundary
Content-Type: text/html

$(cat "$EMAIL_BODY")

--boundary
Content-Type: text/csv
Content-Disposition: attachment; filename="$OUTPUT_FILE"

$(cat "$OUTPUT_FILE")

--boundary--
EOF

echo "Email sent to $EMAIL_TO"
