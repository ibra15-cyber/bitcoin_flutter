import 'dart:convert';
import 'package:http/http.dart' as http;

const List<String> currenciesList = [
  'AUD',
  'BRL',
  'CAD',
  'CNY',
  'EUR',
  'GBP',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'JPY',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'RON',
  'RUB',
  'SEK',
  'SGD',
  'USD',
  'ZAR'
];

const List<String> cryptoList = ['BTC', 'ETH', 'LTC'];

const apiKey = "44B164E2-1799-48A3-B70A-18822286C181";

class CoinData {
  //instead of hardcoding selected currency in the url
  //or depending entirely on controlling the change inside the picker onchange
  //which is still necessary to change selected currency as we move the picker
  //so we pass the selectedCurrency as and when we use the picker here
  //we create a map called cryptoPrices that takes Strings as key and value
  //we iterate the 3 crypto we got each time making sure our url has diff crypto for any selectedCurrency
  //ie for every selected currency 3 urls are gonna be made each for a diff crypto


  Future getCoinData(String selectedCurrency) async {
    Map<String, String> cryptoPrices = {};
    for (String crypto in cryptoList) {
      String requestURL =
          'https://rest.coinapi.io/v1/exchangerate/$crypto/$selectedCurrency?apikey=$apiKey';
      http.Response response = await http.get(Uri.parse(requestURL));

      //here we look to see if we are successful; if true
      //decode the body in json format
      //then truncate the rate and save as rate
      //finally convert or format our double type to string with a 0 fix numbers or decimals
      //assign it as a value to the key crypto ie the crypto currency which are 3 in our case
      //eg cryptoPrices = {"BTC": '3433', "ETC": '08080', "LTC": "7987"};
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        double price = decodedData['rate'];
        cryptoPrices[crypto] = price.toStringAsFixed(0);
        //In case there was a problem getting the data
        //throw this in the app and also print this in the console
      } else {
        print(response.statusCode);
        throw 'Problem with the get request';
      }
    }
    //finally return the map of crypto: string prices
    return cryptoPrices;
  }
}