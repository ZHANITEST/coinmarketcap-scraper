/*
 * 파싱 거래를 위한 테스트 유닛 모듈
 */
module coinmarketcap;

import std.stdio;
import std.net.curl;
import std.conv;
import std.string;
import std.regex;
import std.algorithm.mutation; // reverse

//<td class="text-left">([A-z]{3} [\d]{2}, [\d]{4})<\/td>[\W]+<td>([\d\.]+)<\/td>[\W]+<td>[\d\.]+<\/td>[\W]+<td>[\d\.]+<\/td>[\W]+<td>[\d\.]+<\/td>[\W]+<td>[\d,]+<\/td>[\W]+<td>[\d,]+<\/td>

/**
 *	가격 정보
 */
struct day_price{
    string date;
    string open;
    string high;
    string low;
    string close;
    string volume;
    string market_cap;
}

/*
string[string] AMon = [
    "Jan":"01",
    "Feb":"02",
    "Mar":"03",
    "Apr":"04",
    "May":"05",
    "Jun":"06",
    "Jul":"07",
    "Aug":"08",
    "Sep":"09",
    "Oct":"10",
    "Nov":"11",
    "Dec":"12"
];*/



/**
 *	메인페이지 얻기
 */
string get_index(){
    auto x = get("https://coinmarketcap.com");
    string html = to!string(x);
    return html;
}



/**
 * 얻은 페이지에서 화폐/단위 얻기
 */
string[] get_currency_word(){
    string html = get_index();
    string[] list = [];
    auto r = regex("href=\"/[currenciesassets]+/[A-z\\d-]+/\">([A-z\\d /\\.]+)</a>");
    foreach(x; matchAll(html, r)){
        list ~= x[1];
    }
    return list;
}



/**
 *	상장 일자 얻기
 */
string get_currency_birth(string currency){
    // 화폐 문자열을 url주소에서 인식되게 변경
    currency = currency.replace(" ", "-");
    currency = currency.replace(".", "-");
    currency = currency.replace("/", "");
    
    string url = "https://coinmarketcap.com/currencies/"~currency~"/historical-data/";
    string html = to!string(get(url));
    
    auto r = regex("\"(\\d{2})-(\\d{2})-(\\d{4})\"");
    auto m = match(html, r);
    
    if(m.empty()){
        assert(false);
    }
    
    
    string year = m.front[3];
    string month = m.front[1];
    string day = m.front[2];
    
    return year~month~day;
}



/**
 *	시세 얻어오기
 */
day_price[] get_currency_prices(string currency, string start_date, string end_date){
    // 화폐 문자열을 url주소에서 인식되게 변경
    currency = currency.replace(" ", "-");
    currency = currency.replace(".", "-");
    currency = currency.replace("/", "");
    
    string url = "https://coinmarketcap.com/currencies/"~currency~"/historical-data/?start="~start_date~"&end="~end_date;
    string html = to!string(get(url));
    
    auto r = regex("([\\w]{3} [\\d]{2}, [\\d]{4})<\\/td>\\W+<td>([\\d\\.]+)<\\/td>\\W+<td>([\\d\\.]+)<\\/td>\\W+<td>([\\d\\.]+)<\\/td>\\W+<td>([\\d\\.]+)<\\/td>\\W+<td>([\\d,]+)<\\/td>\\W+<td>([\\d,]+)<\\/td>\\W+");
    auto m = matchAll(html, r);
    
    if(m.empty()){
        assert(false);
    }
	
    day_price[] result;
    foreach(e; m){
        day_price set;
        set.date = e[1];
        set.open = e[2];
        set.high = e[3];
        set.low = e[4];
        set.close = e[5];
        set.volume = e[6];
        set.market_cap = e[7];
        result ~= set;
    }
    reverse(result);
    return result;
}