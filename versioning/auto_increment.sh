VERSION_FILE=$1
CI_PROJECT_URL=$2
API_ACCESS_TOKEN=$3
CI_PROJECT_ID=$4

VERSION=$(grep "^[^# ]" ${VERSION_FILE})

if [ -z "${VERSION}" ]; then
    echo "Error: VERSION is empty"
    exit 1
elif [ "${VERSION}" != "MAJOR" ] && [ "${VERSION}" != "MINOR" ] && [ "${VERSION}" != "HOTFIX" ]; then
    echo "Error: VERSION is not MAJOR, MINOR or HOTFIX"
    exit 2
fi

GITLAB_URL=$(echo ${CI_PROJECT_URL} | awk -F "/" '{print $1 "//" $2$3}')
VAR=$(curl -s -f  --header "PRIVATE-TOKEN: ${API_ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/${CI_PROJECT_ID}/variables/${VERSION}" | jq  -r '.value' )
VAR=$((VAR+1))
curl -s -f --request PUT --header "PRIVATE-TOKEN: ${API_ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/${CI_PROJECT_ID}/variables/${VERSION}" --form "value=${VAR}"

if [ "${VERSION}" == "MAJOR" ]; then
    curl -s -f --request PUT --header "PRIVATE-TOKEN: ${API_ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/${CI_PROJECT_ID}/variables/MINOR" --form "value=0"
    curl -s -f --request PUT --header "PRIVATE-TOKEN: ${API_ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/${CI_PROJECT_ID}/variables/HOTFIX" --form "value=0"
fi

if [ "${VERSION}" == "MINOR" ]; then
    curl -s -f --request PUT --header "PRIVATE-TOKEN: ${API_ACCESS_TOKEN}" "${GITLAB_URL}/api/v4/projects/${CI_PROJECT_ID}/variables/HOTFIX" --form "value=0"
fi