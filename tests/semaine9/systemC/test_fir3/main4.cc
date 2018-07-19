#include "systemc.h"

const sc_uint< 16 > coef[5] =  {18,77,107,77,18};

SC_MODULE( fir ){

  sc_in < bool > clk;
  sc_in < bool> rst;
  sc_in< sc_uint<16> > inp;
  sc_out< sc_uint<16> > outp;

  SC_CTOR( fir ){

    SC_CTHREAD( fir_main, clk.pos());
    reset_signal_is( rst, true);


  };

  void fir_main(){

  	cout << "fir_main oper" << endl;

  	sc_uint<16> vals[5];
	 sc_uint<16> ret;

		outp.write(0);
		wait();

		while(true) {
			for(int i = 4; i > 0; i--) {
				vals[i] = vals[i-1];
			}
			vals[0] = inp.read();
			//cout << "RECEIVING.. " << vals[0].to_int() << endl;

			ret = 0;
			for(int i = 0; i < 5; i++) {
				ret += coef[i] * vals[i];
			}

			outp.write(ret);
			wait();
		}


  }


};

SC_MODULE (tb){

   sc_in < bool > clk;
   sc_out < bool > rst;
   sc_out< sc_uint<16> > inp;
   sc_in< sc_uint<16> > outp;

  void source() {
		sc_uint < 16 > tmp;
		//rest
		inp.write( 0 );
		rst.write( 1 );
		wait();
		rst.write( 0 );
		wait();

		for(int i = 0; i < 64; i++)
		{
			if (i > 23 && i < 29)
				tmp = 256;
			else
				tmp = 0;
			//cout << "SENDING .. " << tmp.to_int() << endl;
			inp.write(tmp);
			wait();
		}

}


	void sink() {
		sc_int <16> datain;

		for(int i=0; i < 64; i++)
		{

			datain = outp.read();
      wait();

			cout << i << " :\t" << datain.to_int() << endl;

		}

		//end sim
		sc_stop();
		cout << "sim stop" << endl;
	}


  SC_CTOR(tb){

    SC_CTHREAD ( source, clk.pos());
    SC_CTHREAD ( sink, clk.pos());

  }


};



 //module connecting fir to tb and run sim


 SC_MODULE( systb ){

	 tb  * tb0;
	 fir * fir0;


	 sc_signal < sc_uint < 16 > > inp_sig;
	 sc_signal < bool > rst_sig;

 	 sc_signal < sc_uint < 16 > >  outp_sig;

   	 sc_clock  clk_sig;

 SC_CTOR( systb )

 	 : clk_sig ("clk_sig", 10, SC_NS)
 	 {

	 cout << "constructor" << endl;

	 tb0 = new tb("tb0");

	 tb0->clk( clk_sig );
	 tb0->rst( rst_sig );
	 tb0->inp( inp_sig );
	 tb0->outp( outp_sig );

	 fir0 = new fir("fir0");

	 fir0->clk( clk_sig );
	 fir0->rst( rst_sig );
	 fir0->inp( inp_sig );
	 fir0->outp( outp_sig );

    }


 	 ~systb(){

 		 delete tb0;
 		 delete fir0;
 		cout << "delete" << endl;
 	 }
 };




 systb *top = NULL;

 int sc_main(int, char* [])
 {

	 top = new systb("top");
	 cout << "sim start" << endl;

	      sc_start(); // 200, SC_NS

	 return 0;

 }
