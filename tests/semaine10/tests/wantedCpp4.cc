#include <systemc.h>

SC_MODULE( fir ){

  sc_in < bool > clk;
  sc_in< sc_uint<32> > inp;
  sc_out< sc_uint<32> > outp;

  sc_uint< 32 > coef[5];

  fir(sc_module_name sc_m_name, sc_uint< 32 > ucoef[5])
  : sc_module(sc_m_name)
  {
    for(int i = 0; i < 5; i++) {
      coef[i] = ucoef[i];
    }
    SC_CTHREAD( fir_main, clk.pos());
  }


  SC_CTOR( fir ){

    SC_CTHREAD( fir_main, clk.pos());
  };

  void fir_main(){

  	cout << "fir_main oper" << endl;

  	sc_uint<32> vals[5];
	 sc_uint<32> ret;

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

SC_MODULE ( sourcer ){

   sc_in < bool > clk;
   sc_out< sc_uint<32> > inp;

  void source() {
		sc_uint < 32 > tmp;

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

  SC_CTOR( sourcer ){

    SC_CTHREAD ( source, clk.pos());

  }


};

SC_MODULE ( sinker ){

   sc_in < bool > clk;
   sc_in< sc_uint<32> > outp;

	void sink() {
		sc_int <32> datain;

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


  SC_CTOR( sinker ){

    SC_CTHREAD ( sink, clk.pos());

  }


};




 //module connecting fir to tb and run sim


 SC_MODULE( systb ){

	 sourcer  * src0;
	 sinker * snk0;
	 fir * fir0;


	 sc_signal < sc_uint < 32 > > inp_sig;

 	 sc_signal < sc_uint < 32 > >  outp_sig;

   	 sc_clock  clk_sig;

 SC_CTOR( systb )

 	 : clk_sig ("clk_sig", 10, SC_NS)
 	 {

	 cout << "constructor" << endl;

	 src0 = new sourcer("src0");

	 src0->clk( clk_sig );
	 src0->inp( inp_sig );

	snk0 = new sinker("snk0");

	 snk0->clk( clk_sig );
	 snk0->outp( outp_sig );

   sc_uint< 32 > ucoef[5] = {18,77,107,77,18};
	 fir0 = new fir("fir0", ucoef);

	 fir0->clk( clk_sig );
	 fir0->inp( inp_sig );
	 fir0->outp( outp_sig );

    }


 	 ~systb(){

 		 delete src0;
		 delete snk0;
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
