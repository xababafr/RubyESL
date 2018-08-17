#include <systemc.h>
#include <iostream>
#include <string>

SC_MODULE( Sourcer ) {

    // clock
    sc_in<bool> clk;

    // inouts
    sc_out< sc_uint<32>  > inp;

    // ivars


    SC_CTOR( Sourcer ) {
        SC_CTHREAD( source, clk.pos() );
    };

    void source ()
    {
        sc_uint<32> tmp;
        sc_uint<32> i;

        cout << "\nSOURCER::BEHAVIOR()\n\n" << endl;
        tmp = 0;
        for(int i = 0; i <= 64; i++)
        {
            if (( i > 23 ) && ( i < 29 ))
            {
                tmp = 256;
            }
            else
            {
                tmp = 0;
            }
            inp.write(tmp);
            wait();
        }
    }
};

SC_MODULE( Fir ) {

    // clock
    sc_in<bool> clk;

    // inouts
    sc_in< sc_uint<32>  > inp;
    sc_out< sc_uint<32>  > outp;

    // ivars
    sc_uint<32>  coef[5];

    Fir(sc_module_name sc_m_name, sc_uint<32>  ucoef[5])
    : sc_module(sc_m_name) {

        for(int i = 0; i <= 5; i++)
        {
            coef[i] = ucoef[i];
        }


        SC_CTHREAD( behavior, clk.pos() );
    }

    SC_CTOR( Fir ) {
        SC_CTHREAD( behavior, clk.pos() );
    };

    void behavior ()
    {
        sc_uint<32>  vals[5];
        sc_uint<32> j;
        sc_uint<32> i;
        sc_uint<32> ret;

        cout << "\nFIR::BEHAVIOR()\n\n" << endl;
        while (true)
        {
            for(int i = 0; i <= 4; i++)
            {
                j = 4 - i;
                vals[j] = vals[j - 1];
            }
            vals[0] = inp.read();
            ret = 0;
            for(int i = 0; i <= 5; i++)
            {
                ret += coef[i] * vals[i];
            }
            outp.write(ret);
            wait();
        }
    }
};

SC_MODULE( Sinker ) {

    // clock
    sc_in<bool> clk;

    // inouts
    sc_in< sc_uint<32>  > outp;

    // ivars


    SC_CTOR( Sinker ) {
        SC_CTHREAD( sink, clk.pos() );
    };

    void sink ()
    {
        sc_uint<32> k;
        sc_uint<32> datain;

        cout << "\nSINKER::BEHAVIOR()\n\n" << endl;
        for(int k = 0; k <= 64; k++)
        {
            datain = outp.read();
            wait();
            cout << (k) << " --> " << (datain) << endl;
        }
        sc_stop();
    }
};


SC_MODULE( System ) {
    //entities
    Sourcer *src0;
    Fir *fir0;
    Sinker *snk0;

    // signals
    sc_signal< sc_uint<32>  > sourcer_inp_fir_inp_sig;
    sc_signal< sc_uint<32>  > fir_outp_sinker_outp_sig;
    sc_clock clk_sig;

    SC_CTOR( System )
    : clk_sig ("clk_sig", 10, SC_NS)
    {
        src0 = new Sourcer("src0");
        src0->clk( clk_sig );
        src0->inp( sourcer_inp_fir_inp_sig  );

        sc_uint<32>  ucoef[5] = {18, 77, 107, 77, 18};
        fir0 = new Fir("fir0", ucoef);
        fir0->clk( clk_sig );
        fir0->inp( sourcer_inp_fir_inp_sig  );
        fir0->outp( fir_outp_sinker_outp_sig  );

        snk0 = new Sinker("snk0");
        snk0->clk( clk_sig );
        snk0->outp( fir_outp_sinker_outp_sig  );

    }

    ~System(){
        delete src0;
        delete fir0;
        delete snk0;
    }
};

System *sys = NULL;

// main
int sc_main(int, char* [])
{
    sys = new System("sys");
    sc_start();
    return 0;
}
