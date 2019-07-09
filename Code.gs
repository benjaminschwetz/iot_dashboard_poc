// Remember adding sheetID under File/Project properties
function appendLines(worksheet, csvData) {
  var id = PropertiesService.getScriptProperties().getProperty('sheetID');
  var ss = SpreadsheetApp.openById(id);
  var sheet = ss.getSheetByName(worksheet);

  var rows = Utilities.parseCsv(csvData);

  for ( var i = 0; i < rows.length; i++ ) {
    sheet.appendRow(rows[i]);
  }
}

function test() {
  Logger.log("Appending fake data");
  appendLines("raw", "12345, Monday, kitchen, temperature, 30\n12346, Tuesday, living room, humidity, 50");
}

function doPost(e) {
  var contents = e.postData.contents;
  var sheetName = e.parameter['sheet'];

  // Append to spreadsheet
  appendLines(sheetName, contents);

  var params = JSON.stringify(e);
  return ContentService.createTextOutput(params);

}

function doGet(e) {
  var sheetName = e.parameter['sheet'];
  var id = PropertiesService.getScriptProperties().getProperty('sheetID');
  var ss = SpreadsheetApp.openById(id);
  var sheet = ss.getSheetByName(sheetName);
  var data = sheet.getDataRange().getValues();


  // Loop through the data in the range and build a string with the CSV data
  // taken from https://developers.google.com/apps-script/articles/docslist_tutorial#section2
  var csvFile = undefined
  if (data.length > 1) {
    var csv = "";
    for (var row = 0; row < data.length; row++) {
      for (var col = 0; col < data[row].length; col++) {
         if (data[row][col].toString().indexOf(",") != -1) {
           data[row][col] = "\"" + data[row][col] + "\"";
         }
      }

      // Join each row's columns
      // Add a carriage return to end of each row, except for the last one
      if (row < data.length-1) {
        csv += data[row].join(",") + "\r\n";
      }
      else {
        csv += data[row];
      }
    }
    csvFile = csv;
  }

  return ContentService.createTextOutput(csvFile);
}

