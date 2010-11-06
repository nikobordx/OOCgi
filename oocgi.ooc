use oocgi
import os/Env
import structs/MultiMap

CGI: class
{
    requestHeaders := MultiMap<String,String> new()
    responseHeaders := MultiMap<String,String> new()
    getArray := MultiMap<String,String> new()
    postArray := MultiMap<String,String> new()
    response : String
    body : String
    init : func
    {
        getEnv("SERVER_SOFTWARE")
        getEnv("SCRIPT_NAME")
        getEnv("SERVER_NAME")
        getEnv("GATEWAY_INTERFACE")
        getEnv("SERVER_PROTOCOL")
        getEnv("SERVER_PORT")
        getEnv("REQUEST_METHOD")
        getEnv("SCRIPT_FILENAME")
        getEnv("QUERY_STRING")
        getEnv("REMOTE_ADDR")
        getEnv("REQUEST_URI")
    
        getArray = parseQuery(requestHeaders["QUERY_STRING"])
        
        if(requestHeaders["REQUEST_METHOD"] == "POST")
        {
            getEnv("CONTENT_TYPE")
            getEnv("CONTENT_LENGTH")
            if(requestHeaders get("CONTENT_LENGTH") == "") { requestHeaders["CONTENT_LENGTH"] = "0" }
        
            n := requestHeaders get("CONTENT_LENGTH") toInt()
            temp: Char*
            temp = gc_malloc(n+1)
            memset(temp,0,n+1)
            fread(temp,1,n,stdin)
            
            postArray = parseQuery(urldecode(temp as String))
        }
    }
    
    parseQuery : func (query: String) -> MultiMap<String,String>
    {
        ret := MultiMap<String,String> new()
        if(query != null)
        {
            secondPart := false
            tempFirst : String = ""
            tempSecond : String = ""
            for(i in 0 .. query size)
            {
                if(query[i] == '&' || i == query size-1)
                {
                    if(secondPart && i == query size-1)
                    {
                        tempSecond = (tempSecond == null) ? query[i] as String : tempSecond+(query[i] as String)
                    }
                    else if(!secondPart && i == query size-1)
                    {
                        tempFirst = (tempFirst == null) ? query[i] as String : tempFirst+(query[i] as String)
                    }
                    ret[tempFirst] = tempSecond
                    secondPart = false
                    tempFirst = ""
                    tempSecond = ""
                }
                else if(query[i] == '=' && !secondPart)
                {
                    secondPart = true
                }
                else
                {
                    if(secondPart)
                    {
                        tempSecond = (tempSecond == null) ? query[i] as String : tempSecond+(query[i] as String)
                    }
                    else
                    {
                        tempFirst = (tempFirst == null) ? query[i] as String : tempFirst+(query[i] as String)
                    }
                }
            }
        }
        ret
    }
    
    urldecode : func(string: String) -> String
    {
        ret : String
        n := string size
        state := 0
        for(i in 0 .. n)
        {  
            if(state == 0)
            {
                if(string[i] != '%')
                {
                    ch := string[i]
                    if(ch == '+') { ch = ' ' }
                    ret = (ret == null) ? (ch as String) : ret+(ch as String)
                }
                else
                {
                    state = 1
                }
            }
            else
            {
                state = 0
                temp := (string[i] as String) + (string[i+1] as String)
                bothDigits := true
                for(j in 0 .. 2)
                {
                    if(!isXDigit(temp[j]))
                    {
                        bothDigits = false
                    }
                }
        
                if(bothDigits)
                {
                    ascii : Int
                    sscanf((temp as Char*),"%x",ascii&)
                
                    ret = (ret == null) ? (ascii as Char) as String : ret+ascii as Char
                    if(i+1 < n) { i += 1 }
                }
            }
        }
        ret
    }
    
    isXDigit : func(c: Char) -> Bool
    {
        return (c == '0' || c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8' || c == '9' || c == 'A' || c == 'B' || c == 'C' || c == 'D' || c == 'E' || c == 'F')
    }
    
    getEnv : func(env: String)
    {
        if(getenv(env) as String != null)
        {
            requestHeaders[env] = getenv(env) as String
        }
    }
    
    setHeader : func(header,contents: String)
    {
        responseHeaders[header] = contents
    }
    
    setBody : func(=body)
    {
    }
    
    forgeResponse : func
    {
        response = ""
        for(i in 0 .. responseHeaders size)
        {
            key := responseHeaders getKeys() get(i)
            val := responseHeaders getAll(key)
            response +=  key + ": " + val + "\n"
        }
        if(responseHeaders["Content-Length"] == null && body != null)
        {
            response += "Content-Length: " + ("%d" format(body size)) + "\n"
        }
        response += "\n\n" + ((body != null) ? body : " ")
    }
    
}
