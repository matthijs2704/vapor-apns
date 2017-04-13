echo "🚀 Building";
swift build
if [[ $? != 0 ]]; 
then 
    echo "❌  Build failed";
    exit 1; 
fi

echo "💼 Building Release";
swift build -c release
if [[ $? != 0 ]]; 
then 
    echo "❌  Build for release failed";
    exit 1; 
fi

echo "🔎 Testing";

swift test
if [[ $? != 0 ]]; 
then 
    echo "❌ Tests failed";
    exit 1; 
fi

echo "✅ Done"
