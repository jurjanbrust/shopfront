#!/bin/bash -e
# https://stripe.com/docs/billing/prices-guide
source .env
if ! test "$STRIPE_SECRET"
then
	echo Please source \$STRIPE_SECRET
	exit
fi

for p in public/*/index.json
do
jq -r '.[]|.name,.sku,.price' $p |
	while read -r name
	read -r sku
	read -r price
	do

	printf "Name: %s SKU: %s Price: %s\n" "$name" "$sku" "$price"

	stripeproduct=data/product/$sku.json
	stripeprice=data/price/$sku.json

	test -s $stripeproduct || curl https://api.stripe.com/v1/products -u ${STRIPE_SECRET}: -d name="$name" > $stripeproduct
	prodid=$(jq -r '.id' < $stripeproduct)
	echo Product ID: $prodid

	test -s $stripeprice || curl https://api.stripe.com/v1/prices -u ${STRIPE_SECRET}: -d product="$prodid" -d unit_amount="$price" -d currency=${CURRENCY:-"usd"} > $stripeprice
	priceid=$(jq -r '.id' < $stripeprice)
	echo Price ID: $priceid

	done
done
