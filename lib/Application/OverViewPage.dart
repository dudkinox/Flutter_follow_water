import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dwr0001/Models/station_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'StationPage.dart';

// ignore: must_be_immutable
class OverViewPage extends StatelessWidget {
  OverViewPage(this.basinID);
  var basinID;
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      home: MyDisplayClass(basinID),
    );
    return materialApp;
  }
}

// ignore: must_be_immutable
class MyDisplayClass extends StatelessWidget {
  MyDisplayClass(this.basinID);
  var basinID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TELEDWR-รายการสถานี',
          style: TextStyle( color: Colors.white, fontFamily: 'Kanit',fontSize: 18.0, fontWeight: FontWeight.w700),),
        elevation: 10.0,
      ),
      body: Center(
        
        child: FutureBuilder<List<StationModel>>(
          future: getStationList(basinID),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<StationModel> station = snapshot.data;
              return ListView.builder(
                itemCount: station.length,
                itemBuilder: (context, int i) => Column(
                  children: [
                    new ListTile(
                      leading: Container(
                      child: Material(
                        shape: CircleBorder(),
                        elevation: 2.0,
                  child: CircleAvatar(
                        radius: 18.0,
                        child: CircleAvatar(
                          radius: 0,
                          backgroundColor: Colors.greenAccent,
                        ),
                        backgroundColor: station[i].CURR_STATUS == "0"
                            ? Colors.green
                            : station[i].CURR_STATUS == "1"
                            ? Colors.yellow
                            : station[i].CURR_STATUS == "2"
                            ? Colors.red
                            : station[i].CURR_STATUS == "3"
                            ? Colors.white
                            : station[i].CURR_STATUS == "4"
                            ? Colors.grey
                            : station[i].CURR_STATUS == "5"
                            ? Colors.black
                            : Colors.green,
                      ),
              ),
            ),
                      title: new Text(station[i].STN_ID,
                      style: TextStyle( color: Colors.black54, fontFamily: 'Kanit',fontSize: 18.0, fontWeight: FontWeight.w400),),
                      subtitle: new Text(station[i].STN_Name,
                        style: TextStyle( color: Colors.black54, fontFamily: 'Kanit',fontSize: 14.0, fontWeight: FontWeight.w200),),
                      trailing: Wrap(
                        spacing: 12, // space between two icons
                        children: <Widget>[
                          Icon(Icons.add_alert), // icon-1
                          Icon(Icons.arrow_forward_ios), // icon-2
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    StationPage(stn_id: station[i].STN_ID)));
                      },
                      onLongPress: () {
                        print(
                          Text("Long Pressed"),
                        );
                      },
                    ),
                    new ListBody(
                      children: <Widget>[],
                    )
                  ],
                ),
              );
              ////print('Response JsonDecode: $station');
              //return Text(station.length.toString());
              ////Text("STN_ID: ${station.STN_ID}\nSTN_Name: ${station.STN_Name}\nCURR_Acc_Rain_1_D: ${station.CURR_Acc_Rain_1_D}\nCURR_Acc_Rain_12_H: ${station.CURR_Acc_Rain_12_H}\nCURR_Acc_Rain_15_M: ${station.CURR_Acc_Rain_15_M}\nCURR_Acc_Rain_30_M: ${station.CURR_Acc_Rain_30_M}\nCURR_Acc_Rain_60_M: ${station.CURR_Acc_Rain_60_M}\nCURR_FLOW: ${station.CURR_FLOW}\nCURR_Water_D_Level_MSL: ${station.CURR_Water_D_Level_MSL}\nCURR_Water_U_Level_MSL: ${station.CURR_Water_U_Level_MSL}\nLAST_UPDATE: ${station.LAST_UPDATE}\n ");
            } else if (snapshot.hasError) {
              //print('snapshot.error: ${snapshot.error.toString()}');
              return Text(snapshot.error.toString());
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}



Future<StationModel> getStation() async {
  final String url =
      "http://tele-maeklong.dwr.go.th/webservice/webservice_mk_json_id?stn_id=TC140805";
  //final String url = "http://tele-maeklong.dwr.go.th/webservice/webservice_mk_json";
  //https://localhost:44303/webservice/webservice_mk_json_id?stn_id=TC140805
  //final String url = "https://jsonplaceholder.typicode.com/todos/1";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    final station = jsonDecode(response.body);
    print('Response JsonDecode: $station');
    return StationModel.fromJson(station);
  } else {
    throw Exception();
  }
}

List<StationModel> parseStation(String responseBody) {
  final parsed = json.decode(responseBody);
  return parsed
      .map<StationModel>((json) => StationModel.fromJson(json))
      .toList();
}

Future<List<StationModel>> getStationList(var basinId) async {
  //final response = await http.get('http://192.168.1.2:8000/products.json');
  final String url = basinId == 1
      ? "http://tele-maeklong.dwr.go.th/webservice/webservice_mk_json"
      : basinId == 2
      ? "http://tele-salawin.dwr.go.th/webservice/webservice_sl_json"
      : basinId == 3
      ? "http://tele-kokkhong.dwr.go.th/webservice/webservice_kk_json"
      : "http://tele-maeklong.dwr.go.th/webservice/webservice_mk_json";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return parseStation(response.body);
  } else {
    throw Exception('Unable to fetch products from the REST API');
  }
}
