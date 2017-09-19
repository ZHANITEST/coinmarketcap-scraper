import std.stdio;
import std.conv;
import coinmarketcap;

void main()
{
	// 라이트코인 시세 데이터 가져오기
	string type = "litecoin";
    string ltc_birth = get_currency_birth(type);
    day_price[] x = get_currency_prices(type, ltc_birth, "20170904");

    foreach(e; x){
    	writeln(e);
	}
}