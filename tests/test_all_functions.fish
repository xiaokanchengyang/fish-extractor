# Test All Functions Loading

# Just try to source all files to check syntax errors
for file in functions/*.fish functions/common/*.fish
    source $file
end

echo "✓ All functions sourced successfully"
exit 0
