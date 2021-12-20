// import 'dart:html';

import 'package:bitcoin_tracker_flutter/coin_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;



class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  //our default selectedCurrency is "AUD"
  //which will get changed in the pickle as we invoke onchanged by moving the wheel
  String selectedCurrency = 'AUD';


  //here we needed a DropDownButton widget that will contain drop down button items children for our android
  //but in order not to hardcode it for all the 21 strings of currencies,
  // we want a method to encapsulate everything currency, then a for loop to create for each currency
  //then we make a list of drop down menu items
  //we iterate through the list and each time creating a drop down menu item
  //and since we will be creating for 21 diff currencies we needed a variable to hold
  //and each time adding the variable into our list
  //i could even remove the varibale and append the DropDownMenuItem in the list directly
  //since it will take DropDownMenu will take children DropDownMenuItems, we pass it as children
  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      dropdownItems.add(DropdownMenuItem(
        child: Text(currency),
        value: currency,
      ),
      );
      // dropdownItems.add(newItem);
    }

    return DropdownButton<String>(
      //value is default for this widget and it meant the one to display
      //items are like the list of children expected
      //onChanged property is like when you select a value what should happen
      //so first the new value selected have to have its state changed
      //therefore we put it into a setState method
      //the diff between picker and dropdown is picker onselect sees things with index
      //but drop down button see them based on value
      //the value we selected to be selected currency was hardcoded initially
      // but anytime a new item is selected we make that item the selected item
      //we only need the setState to update it
      value: selectedCurrency,
      items: dropdownItems,
      onChanged: (dynamic value) {
        setState(() {
          selectedCurrency = value;
          getData();
        });
      },
    );
  }

  //we need a method to return a CupertinoPicker that will have a list of Text widgets as children
  //so our method returns the needful ie CupertinoPicker and our list of Text widget
  CupertinoPicker iOSPicker() {
    //to create our text widgets we create a list because there are going to be a list
    //then we iterate in the 21 currenciesList each time converting the currencies that are strings into a string of our text
    //adding it to our list on the way
    //because cupertino picker is expecting a list as children we can pass our list to its children
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }

    return CupertinoPicker(
      //itemExtend ie height  and onSelectedItemChanged are required by default
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      //so anytime we move or select a diff item this method record using indexes
      //since we want to be able to tap into each of our passed currencies we can achieve that using the index
      //unfortunately using just the index does not return the currency we need hence
      //we specify saying for every index map it to the items in the currenciesList
      //then update getData(); so that everytime a diff selectedItem will be passed to the url in getData
      //else the hardcoded selected data will still be the only selected currencies anytime getData is called int init state
      //and very importantly, since we know selected currency and getData are continuously going to change we wrap it in a setState
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurrency = currenciesList[selectedIndex];
          getData();
        });
      },
      children: pickerItems,
    );
  }

  //here we creating a map of string string key value pair
  //we assing a variable of a type bool to false
  Map<String, String> coinValues = {};
  bool isWaiting = false;

  //our getData() is going to wrap our coin class
  // async because our get coin data method is a future in the other file
  //we try to get to the coinData class using static approach
  // because we do not need to make an object after all its only one method we are calling
  //we call it passing each currency at a time
  //we expect to return getCoinData to return crytoPrices
  // which is a string string map of crypto and prices for all 3 crypto
  //so our data here too has same return type as our cryptoPrices Map
  //since its state will keep changing based on the currency selected we put our coinValues inside it
  //we could have defined coinValues inside the method we did it outside because it should be seen by other parts of the code
  void getData() async {
    isWaiting = true;
    try {
      var data = await CoinData().getCoinData(selectedCurrency);
      isWaiting = false;
      setState(() {
        coinValues = data;
      });
    } catch (e) {
      print(e);
    }
  }

  //we want our getData to load anytime the page refereshes hence we wrapped it into initState
  @override
  void initState() {
    super.initState();
    getData();
  }

  //since we needed more than one card to display each crypto we need a column widget to contain our cards as list
  //which means we could create a list of cards of a return type Card that has been extracted into a class CryptoCard
  //then we pass the list of cards into our parent widget column
  //then formatting the column once

  //for us not to repeat each of the card which is weird as the only thing changing for all 3 currencies
  // are the for each crypto card, the selected currency and its correspond price
  //we extracted the Card into a class
  //we create a list to hold a card for each of the 3 crypto
  //each time adding the created crypto card into our cryptoCards list

  //so our method is returning a widget column hence it must be of return type column
  Column makeCards() {

    List<CryptoCard> cryptoCards = [];
    for (String crypto in cryptoList) {
      cryptoCards.add(
        CryptoCard(
          cryptoCurrency: crypto,
          selectedCurrency: selectedCurrency,
          value: isWaiting ? '?' : coinValues[crypto],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cryptoCards,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          makeCards(),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropdown(),
            // Platform.isIOS ? iOSPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  var value;
  String selectedCurrency;
  String cryptoCurrency;

   CryptoCard({
    required this.value,
    required this.selectedCurrency,
    required this.cryptoCurrency,
  });



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $cryptoCurrency = $value $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}