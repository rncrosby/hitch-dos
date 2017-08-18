import os
from flask import json
from flask import Flask, render_template, request
import stripe

app = Flask(__name__)

stripe_keys = {
  'secret_key': 'sk_test_ZnojzdXoXMNHVzioAQvHjZLy',
  'publishable_key': 'pk_test_NChUHegmsfKqqrvMQansdJX2'
}

stripe.api_key = 'sk_test_ZnojzdXoXMNHVzioAQvHjZLy'

@app.route('/charge', methods=['POST'])
def charge():
    json = request.get_json(force=True)
    token = json['token']
    amount = json['amount']
    email = json['email']
    pFrom = json['pFrom']
    pTo = json['pTo']
    paymentID = json['paymentID']
    charge = stripe.Charge.create(
        amount=amount,
        currency="usd",
        description=paymentID,
        source=token,
                                  metadata = { 'from' : pFrom, 'to' : pTo }
        )
    if charge:
        return "Success"
    else:
        return "Error"

if __name__ == "__main__":
    app.run(debug = True, host= '0.0.0.0')
