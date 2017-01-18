<Query Kind="Statements">
  <Reference>C:\Dev\Trebuchet\ThirdParty\Bin\Newtonsoft.Json.dll</Reference>
  <Namespace>Newtonsoft.Json</Namespace>
</Query>

/*

The MIT License (MIT)
Copyright (c) 2016 W. Jacob Harris

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

//Recommend Linqpad 4 for easy viewing of these files.  www.linqpad.net


//Initialize Web Client.
using(System.Net.WebClient wc = new System.Net.WebClient())
{
	string responseBody = "";

	wc.Headers.Add("Accept","text/json");


	try{
		responseBody = wc.DownloadString("http://127.0.0.1/Trebuchet.WebApi/api/V1/serviceinfo");
	}catch(Exception ex)
	{
		ex.Dump();
	}

	//A simple routine to make the json more readable, not requried for functionality	
	using (var stringReader = new StringReader(responseBody))
        using (var stringWriter = new StringWriter())
        {
            var jsonReader = new JsonTextReader(stringReader);
            var jsonWriter = new JsonTextWriter(stringWriter) { Formatting = Newtonsoft.Json.Formatting.Indented };
            jsonWriter.WriteToken(jsonReader);
            responseBody =  stringWriter.ToString();
        }
	
	responseBody.Dump(); //Special to linqpad, makes the output nice to read :)
}