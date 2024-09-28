#!/bin/bash

COMMON_DOMAINS=("dynalias.com" "justpaste.it" "pandashield.com" "geti2p.net" "sslproxy.gateway" "cpuwebdev.selfip.net")

generate_random_string() {
    echo $(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1)
}

generate_poison_subdomain() {
    local base_domain=$1
    local third_party_domain=$2
    local random_string=$(generate_random_string)
    echo "$random_string.$third_party_domain.$base_domain"
}

perform_dns_lookup() {
    local subdomain=$1
    local result=$(dig +short "$subdomain")

    if [ -n "$result" ]; then
        echo "Name: $subdomain., Data: $result"
    else
        echo "Name: $subdomain., No response"
    fi
}

echo -n "Enter domain: "
read domain

echo "Lookup"

poisoning_detected=false

for third_party_domain in "${COMMON_DOMAINS[@]}"; do
    subdomain=$(generate_poison_subdomain "$domain" "$third_party_domain")

    lookup_result=$(perform_dns_lookup "$subdomain")

    if [[ $lookup_result == *"Data:"* ]]; then
        poisoning_detected=true
    fi

    echo "$lookup_result"
done

if [ "$poisoning_detected" = true ]; then
    echo "Result: Likely vulnerable to poisoning."
else
    echo "Result: No poisoning detected."
fi
