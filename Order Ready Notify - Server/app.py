from flask import Flask, send_file, jsonify, request
import json
import os
from tempfile import NamedTemporaryFile
from InvoiceGenerator.api import Invoice, Item, Client, Provider, Creator
from InvoiceGenerator.pdf import SimpleInvoice
import sys

os.environ["INVOICE_LANG"] = "en"
provider = Provider('United Tortilla Company', bank_account='2600420569', bank_code='2010')
creator = Creator('William Tortilla')
exe_path = sys._MEIPASS if getattr(sys, 'frozen', False) else os.path.dirname(os.path.abspath(__file__))
app = Flask(__name__)

@app.route('/api/data', methods=['GET'])
def get_data():
    try:
        with open("database.json", "r") as file:
            data = file.read()
            return jsonify(json.loads(data))
    except FileNotFoundError:
        return "File not found", 404
    except Exception as e:
        return str(e), 500
    
@app.route('/download_invoice', methods=['POST'])
def download_invoice():
    data = request.form.get('CustomerID')
    generateInvoice(int(data))
    current_directory = os.getcwd()
    invoice_directory = os.path.join(current_directory, "invoice.pdf")
    return send_file(invoice_directory, as_attachment=True)

def generateInvoice(CustomerID: int):
    with open("database.json", "r") as file:
        data = json.load(file)
    for customer in data["CustomerInfo"]:
        if customer["customerID"] == CustomerID:
            found_customer = customer
            break 
    for order in data["Orders"]:
        if order["customerID"] == CustomerID:
            found_order = order
            break 

    client = Client(found_customer["name"])
    invoice = Invoice(client, provider, creator)
    invoice.currency = '$'
    invoice.currency_locale = 'en_US.UTF-8'
    for item in found_order["items"]:
        name = findProductName(data ,item["productID"])
        price = findProductPrice(data ,item["productID"])
        quantity = item["quantity"]
        invoice.add_item(Item(quantity,price,name))

    pdf = SimpleInvoice(invoice)
    pdf.gen("invoice.pdf", generate_qr_code=True)

def findProductName(data, ProductID):
    products = data["Products"]

    for product in products:
        if product["productID"] == ProductID:
            return product["name"]

def findProductPrice(data,ProductID):
    products = data["Products"]

    for product in products:
        if product["productID"] == ProductID:
            return product["price"]

if __name__ == '__main__':
    app.run(host='0.0.0.0')