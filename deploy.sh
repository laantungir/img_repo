


eval `ssh-agent -s`
ssh-add ~/.ssh/lt_github
git add .; 
git commit --allow-empty-message -m '' ;
git push origin main; 

# Update version and include new version in manifest.json
npm version patch;
VERSION=$(jq -r '.version' package.json);
jq --arg v "$VERSION" '.version |= $v' static/manifest.json > static/updated_manifest.json;
mv static/updated_manifest.json static/manifest.json;

# Create a version file that can be read from the web page.
echo "export const jsonVersion = {\"version\": \"$VERSION\"}" > src/lib/version.mjs


