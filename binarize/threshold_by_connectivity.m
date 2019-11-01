function I = threshold_by_connectivity( B, T )

    I = B ;
    I1 = imtranslate( B, [0 T] );
    I2 = imtranslate( B, [0 -T] );
    I3 = imtranslate( B, [T 0] );
    I4 = imtranslate( B, [-T 0] );

    I = I | I1 | I2 | I3 | I4 ;
    
end