#include "systemc.h"

const sc_uint< 16 > coef[5] =  {18,77,107,77,18};

SC_MODULE( fir ){

  sc_in < bool > clk;
  sc_in < bool> rst;
  sc_in< sc_int<16> > inp;
  sc_out< sc_int<16> > outp;

  SC_CTOR( fir ){

    SC_CTHREAD( fir_main, clk.pos());
    reset_signal_is( rst, true);


  };

  void fir_main(){

  	cout << "fir_main oper" << endl;

  	sc_uint< 16 > taps[5];

  	//rest is wrote here till first wait

  	for (int i = 4; i > 0; i--) {

  		taps[i] = 0;

  	}

  	wait();

  	while(true){

  		//read input into shift register
  		for (int i = 4; i > 0; i--) {

  			taps[i] = taps[i-1];

  		}

  			taps[0] = in_val;


  			// perfom multiplay and accumulate
  			for (int i = 0; i < 5; i++) {

  				out_val += coef[i]*taps[i];


  			}

  			outp.write(out_val);

  		wait();

  	}//while


  }


};

SC_MODULE (tb){

   sc_in < bool > clk;
   sc_out < bool > rst;
   sc_out< sc_int<16> > inp;
   sc_in< sc_int<16> > outp;

  void source() {
		sc_int < 16 > tmp;
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
		}

}


	void sink() {
		sc_int <16> datain;

		for(int i=0; i < 64; i++)
		{

			datain = outp.read();
      wait();

			fprintf(outfp, "%d\n", (int)datain);
			cout << i << " :\t" << datain.to_double() << endl;

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


	 sc_signal < sc_int < 16 > > inp_sig;
	 sc_signal < bool > rst_sig;

 	 sc_signal < sc_int < 16 > >  outp_sig;

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
