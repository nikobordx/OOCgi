use oocgi
import oocgi

main : Func -> Int
{
	test := CGI new() // initialize our cgi object (basic http headers and env variables are loaded by constructor
	test setHeader("Status","200") // set status code to 200 OK
	test setHeader("Content-type","text/html") // set the content-type to html
	html : String = "<html><body>"
	if(test getArray get("name") != null) // always check that the GET or POST parameter you want to use is not null, else your program may crash
	{
		html += "<p>Hello, " + test getArray get("name") + " !!!</p>"
	}
	else if(test requestHeaders get("REMOTE_ADDR") != null)
	{
		html += "<p>Get out stranger " + test requestHeaders get("REMOTE_ADDR") +" !!! I KEEL YOU!!!</p>"
	}
	else
	{
		// oO your server does not give REMOTE_ADDR to the cgi application, thus is not CGI/1.1 compliant ;p
		html += "<p>...</p>"
	}
	html += "</body></html>"
	test setBody(html) // set response body to the html code we wrote
	test forgeResponse() // forge response
	test response print() // print the response (this is equivalent to sending it back to server)
	
	0
}