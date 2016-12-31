#define rol(x,n) ((x << n) | (x >> (64-n)))
#define ror(x,n) ((x >> n) | (x << (64-n)))
#define Ch(x,y,z) ((x & y) ^ ( (~x) & z))
#define Maj(x,y,z) ((x & y) ^ (x & z) ^ (y & z))
#define Sigma0(x) ((ror(x,28))  ^ (ror(x,34)) ^ (ror(x,39)))
#define Sigma1(x) ((ror(x,14))  ^ (ror(x,18)) ^ (ror(x,41)))
#define sigma0(x) ((ror(x,1))  ^ (ror(x,8)) ^(x>>7))
#define sigma1(x) ((ror(x,19)) ^ (ror(x,61)) ^(x>>6))

#define SWAP64(n) \
  (((n) << 56)                                        \
   | (((n) & 0xff00) << 40)                        \
   | (((n) & 0xff0000) << 24)                        \
   | (((n) & 0xff000000) << 8)                        \
   | (((n) >> 8) & 0xff000000)                        \
   | (((n) >> 24) & 0xff0000)                        \
   | (((n) >> 40) & 0xff00)                        \
   | ((n) >> 56))

/* These two functions are momentum/PTS specific */
#define MOSTLY_SWAP64(n) \
  (((n) << 56)                                        \
   | (((n) & 0xff00) << 40)                        \
   | (((n) & 0xff0000) << 24)                        \
   | (((n) & 0xff000000) << 8)                        \
   | (((n) >> 8) & 0xff000000)                        \
   | (((n) >> 24) & 0xff0000)                        \
   | (((n) >> 40) & 0xff00))

/* We're just going to use the byte-swapped hash instead,
 * and recompute on a hash collision */
#define NUKE_THE_HIGH_BITS(n)  (n & 0xffffffffffffULL) 
// (| ((n >> 6) & 0x3000000000000))

const unsigned int64 iv512[8] = {
  0x6a09e667f3bcc908LL,
  0xbb67ae8584caa73bLL,
  0x3c6ef372fe94f82bLL,
  0xa54ff53a5f1d36f1LL,
  0x510e527fade682d1LL,
  0x9b05688c2b3e6c1fLL,
  0x1f83d9abfb41bd6bLL,
  0x5be0cd19137e2179LL
};

const unsigned int64 k[] = {
	0x428a2f98d728ae22LL, 0x7137449123ef65cdLL, 0xb5c0fbcfec4d3b2fLL,
	    0xe9b5dba58189dbbcLL,
	0x3956c25bf348b538LL, 0x59f111f1b605d019LL, 0x923f82a4af194f9bLL,
	    0xab1c5ed5da6d8118LL,
	0xd807aa98a3030242LL, 0x12835b0145706fbeLL, 0x243185be4ee4b28cLL,
	    0x550c7dc3d5ffb4e2LL,
	0x72be5d74f27b896fLL, 0x80deb1fe3b1696b1LL, 0x9bdc06a725c71235LL,
	    0xc19bf174cf692694LL,
	0xe49b69c19ef14ad2LL, 0xefbe4786384f25e3LL, 0x0fc19dc68b8cd5b5LL,
	    0x240ca1cc77ac9c65LL,
	0x2de92c6f592b0275LL, 0x4a7484aa6ea6e483LL, 0x5cb0a9dcbd41fbd4LL,
	    0x76f988da831153b5LL,
	0x983e5152ee66dfabLL, 0xa831c66d2db43210LL, 0xb00327c898fb213fLL,
	    0xbf597fc7beef0ee4LL,
	0xc6e00bf33da88fc2LL, 0xd5a79147930aa725LL, 0x06ca6351e003826fLL,
	    0x142929670a0e6e70LL,
	0x27b70a8546d22ffcLL, 0x2e1b21385c26c926LL, 0x4d2c6dfc5ac42aedLL,
	    0x53380d139d95b3dfLL,
	0x650a73548baf63deLL, 0x766a0abb3c77b2a8LL, 0x81c2c92e47edaee6LL,
	    0x92722c851482353bLL,
	0xa2bfe8a14cf10364LL, 0xa81a664bbc423001LL, 0xc24b8b70d0f89791LL,
	    0xc76c51a30654be30LL,
	0xd192e819d6ef5218LL, 0xd69906245565a910LL, 0xf40e35855771202aLL,
	    0x106aa07032bbd1b8LL,
	0x19a4c116b8d2d0c8LL, 0x1e376c085141ab53LL, 0x2748774cdf8eeb99LL,
	    0x34b0bcb5e19b48a8LL,
	0x391c0cb3c5c95a63LL, 0x4ed8aa4ae3418acbLL, 0x5b9cca4f7763e373LL,
	    0x682e6ff3d6b2b8a3LL,
	0x748f82ee5defb2fcLL, 0x78a5636f43172f60LL, 0x84c87814a1f0ab72LL,
	    0x8cc702081a6439ecLL,
	0x90befffa23631e28LL, 0xa4506cebde82bde9LL, 0xbef9a3f7b2c67915LL,
	    0xc67178f2e372532bLL,
	0xca273eceea26619cLL, 0xd186b8c721c0c207LL, 0xeada7dd6cde0eb1eLL,
	    0xf57d4f7fee6ed178LL,
	0x06f067aa72176fbaLL, 0x0a637dc5a2c898a6LL, 0x113f9804bef90daeLL,
	    0x1b710b35131c471bLL,
	0x28db77f523047d84LL, 0x32caab7b40c72493LL, 0x3c9ebe0a15c9bebcLL,
	    0x431d67c49c100d4cLL,
	0x4cc5d4becb3e42b6LL, 0x597f299cfc657e2aLL, 0x5fcb6fab3ad6faecLL,
	    0x6c44198c4a475817LL,
};


static inline void sha512_block(unsigned int64 *H, const varying int32 seed, const uniform unsigned int64 data[5], const uniform int base)
{
  unsigned int64 w[16];

  unsigned int32 t32 = base+seed*8;
  w[0] = data[0];
  w[0] |= t32;
  w[0] = SWAP64(w[0]);
  w[1] = data[1];
  w[2] = data[2];
  w[3] = data[3];
  w[4] = data[4];
  //  w[5] = 0;     
  //w[6] = 0;     
  //w[7] = 0;     /* These do not get used until after  */
  //w[8] = 0;     /* a later assignment - my unrolled code eliminates */
  //w[9] = 0;     /* the zero uses.  Eliminating the initialization */
  //w[10] = 0;    /* to help the compiler a bit. */
  //w[11] = 0;
  //w[12] = 0;
  //w[13] = 0;
  //w[14] = 0;
  w[15] = 0x120; /* SWAP64(0x2001000000000000ULL); */

  unsigned int64 t1, t2;

  /* i=0 */
  unsigned int64 e = 0xf7689eb47ab51f91ULL + w[0];
  unsigned int64 a = 0x954d6b38bcfcddf5ULL + w[0];
  
  /* i=1 */
  t1 = 0x90bb1e3d1f312338ULL + Sigma1(e) + Ch(e, 0x510e527fade682d1LL, 0x9b05688c2b3e6c1fLL) + w[1];
  t2 = Maj(a, 0x6a09e667f3bcc908LL, 0xbb67ae8584caa73bLL) + Sigma0(a);
  
  unsigned int64 f = e;
  e = iv512[2] + t1;
  unsigned int64 b = a;
  a = t1 + t2;
  
  /* i=2 */
  t1 = 0x50c6645c178ba74eULL + Sigma1(e) + Ch(e, f, 0x510e527fade682d1LL) + w[2];
  t2 = Maj(a, b, 0x6a09e667f3bcc908LL) + Sigma0(a);
  
  unsigned int64 g = f;
  f = e;
  e = iv512[1] + t1;
  unsigned int64 c = b;
  b = a;
  a = t1 + t2;
  
  /* i=3 */
  t1 = 0x3ac42e252f705e8dULL + w[3] + Sigma1(e) + Ch(e, f, g);
  t2 = Maj(a, b, c) + Sigma0(a);
  
  unsigned int64 h = g;
  g = f;
  f = e;
  e = 0x6a09e667f3bcc908LL + t1;
  unsigned int64 d = c;
  c = b;
  b = a;
  a = t1 + t2;
  
  /* i=4 */
  t1 = k[4] + w[4] + h + Sigma1(e) + Ch(e, f, g);
  t2 = Maj(a, b, c) + Sigma0(a);
  
  h = g;
  g = f;
  f = e;
  e = d + t1;
  d = c;
  c = b;
  b = a;
  a = t1 + t2;
  
  /* i=5 */
  t1 = k[5] + h + Sigma1(e) + Ch(e, f, g);
  t2 = Maj(a, b, c) + Sigma0(a);
  
  h = g;
  g = f;
  f = e;
  e = d + t1;
  d = c;
  c = b;
  b = a;
  a = t1 + t2;

  t1 = k[6] + h + Sigma1(e) + Ch(e, f, g);
  t2 = Maj(a, b, c) + Sigma0(a);
  
  h = g;
  g = f;
  f = e;
  e = d + t1;
  d = c;
  c = b;
  b = a;
  a = t1 + t2;
    
  t1 = k[7] + h + Sigma1(e) + Ch(e, f, g);
  t2 = Maj(a, b, c) + Sigma0(a);
  
  h = g;
  g = f;
  f = e;
  e = d + t1;
  d = c;
  c = b;
  b = a;
  a = t1 + t2;
    

  for (int i = 8; i < 15; i++) {
    t1 = k[i] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  }
  

  t1 = k[15] + 0x120ULL + h + Sigma1(e) + Ch(e, f, g);
  t2 = Maj(a, b, c) + Sigma0(a);
    
  h = g;
  g = f;
  f = e;
  e = d + t1;
  d = c;
  c = b;
  b = a;
  a = t1 + t2;



  w[0] = sigma0(w[1]) + w[0];
    t1 = k[16] + w[0] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[1] =sigma1(0x120ULL) + sigma0(w[2]) + w[1];
    t1 = k[17] + w[1] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[2] =sigma1(w[0]) + sigma0(w[3]) + w[2];
    t1 = k[18] + w[2] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[3] =sigma1(w[1]) + sigma0(w[4]) + w[3];
    t1 = k[19] + w[3] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[4] =sigma1(w[2]) + w[4];
    t1 = k[20] + w[4] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[5] =sigma1(w[3]);
    t1 = k[21] + w[5] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[6] =sigma1(w[4]) + 0x120ULL;
    t1 = k[22] + w[6] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[7] =sigma1(w[5]) + w[0];
    t1 = k[23] + w[7] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[8] =sigma1(w[6]) + w[1];
    t1 = k[24] + w[8] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[9] =sigma1(w[7]) + w[2];
    t1 = k[25] + w[9] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[10] =sigma1(w[8]) + w[3];
    t1 = k[26] + w[10] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[11] =sigma1(w[9]) + w[4];
    t1 = k[27] + w[11] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[12] =sigma1(w[10]) + w[5];
    t1 = k[28] + w[12] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[13] =sigma1(w[11]) + w[6];
    t1 = k[29] + w[13] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[14] =sigma1(w[12]) + 0x2000000000000093ULL + w[7]; /* sigma0(0x120ULL) */
    t1 = k[30] + w[14] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[15] =sigma1(w[13]) + sigma0(w[0]) + w[15] + w[8];
    t1 = k[31] + w[15] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[0] =sigma1(w[14]) + sigma0(w[1]) + w[0] + w[9];
    t1 = k[32] + w[0] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[1] =sigma1(w[15]) + sigma0(w[2]) + w[1] + w[10];
    t1 = k[33] + w[1] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[2] =sigma1(w[0]) + sigma0(w[3]) + w[2] + w[11];
    t1 = k[34] + w[2] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[3] =sigma1(w[1]) + sigma0(w[4]) + w[3] + w[12];
    t1 = k[35] + w[3] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[4] =sigma1(w[2]) + sigma0(w[5]) + w[4] + w[13];
    t1 = k[36] + w[4] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[5] =sigma1(w[3]) + sigma0(w[6]) + w[5] + w[14];
    t1 = k[37] + w[5] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[6] =sigma1(w[4]) + sigma0(w[7]) + w[6] + w[15];
    t1 = k[38] + w[6] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[7] =sigma1(w[5]) + sigma0(w[8]) + w[7] + w[0];
    t1 = k[39] + w[7] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[8] =sigma1(w[6]) + sigma0(w[9]) + w[8] + w[1];
    t1 = k[40] + w[8] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[9] =sigma1(w[7]) + sigma0(w[10]) + w[9] + w[2];
    t1 = k[41] + w[9] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[10] =sigma1(w[8]) + sigma0(w[11]) + w[10] + w[3];
    t1 = k[42] + w[10] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[11] =sigma1(w[9]) + sigma0(w[12]) + w[11] + w[4];
    t1 = k[43] + w[11] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[12] =sigma1(w[10]) + sigma0(w[13]) + w[12] + w[5];
    t1 = k[44] + w[12] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[13] =sigma1(w[11]) + sigma0(w[14]) + w[13] + w[6];
    t1 = k[45] + w[13] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[14] =sigma1(w[12]) + sigma0(w[15]) + w[14] + w[7];
    t1 = k[46] + w[14] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[15] =sigma1(w[13]) + sigma0(w[0]) + w[15] + w[8];
    t1 = k[47] + w[15] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[0] =sigma1(w[14]) + sigma0(w[1]) + w[0] + w[9];
    t1 = k[48] + w[0] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[1] =sigma1(w[15]) + sigma0(w[2]) + w[1] + w[10];
    t1 = k[49] + w[1] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[2] =sigma1(w[0]) + sigma0(w[3]) + w[2] + w[11];
    t1 = k[50] + w[2] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[3] =sigma1(w[1]) + sigma0(w[4]) + w[3] + w[12];
    t1 = k[51] + w[3] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[4] =sigma1(w[2]) + sigma0(w[5]) + w[4] + w[13];
    t1 = k[52] + w[4] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[5] =sigma1(w[3]) + sigma0(w[6]) + w[5] + w[14];
    t1 = k[53] + w[5] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[6] =sigma1(w[4]) + sigma0(w[7]) + w[6] + w[15];
    t1 = k[54] + w[6] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[7] =sigma1(w[5]) + sigma0(w[8]) + w[7] + w[0];
    t1 = k[55] + w[7] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[8] =sigma1(w[6]) + sigma0(w[9]) + w[8] + w[1];
    t1 = k[56] + w[8] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[9] =sigma1(w[7]) + sigma0(w[10]) + w[9] + w[2];
    t1 = k[57] + w[9] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[10] =sigma1(w[8]) + sigma0(w[11]) + w[10] + w[3];
    t1 = k[58] + w[10] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[11] =sigma1(w[9]) + sigma0(w[12]) + w[11] + w[4];
    t1 = k[59] + w[11] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[12] =sigma1(w[10]) + sigma0(w[13]) + w[12] + w[5];
    t1 = k[60] + w[12] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[13] =sigma1(w[11]) + sigma0(w[14]) + w[13] + w[6];
    t1 = k[61] + w[13] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[14] =sigma1(w[12]) + sigma0(w[15]) + w[14] + w[7];
    t1 = k[62] + w[14] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[15] =sigma1(w[13]) + sigma0(w[0]) + w[15] + w[8];
    t1 = k[63] + w[15] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[0] =sigma1(w[14]) + sigma0(w[1]) + w[0] + w[9];
    t1 = k[64] + w[0] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[1] =sigma1(w[15]) + sigma0(w[2]) + w[1] + w[10];
    t1 = k[65] + w[1] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[2] =sigma1(w[0]) + sigma0(w[3]) + w[2] + w[11];
    t1 = k[66] + w[2] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[3] =sigma1(w[1]) + sigma0(w[4]) + w[3] + w[12];
    t1 = k[67] + w[3] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[4] =sigma1(w[2]) + sigma0(w[5]) + w[4] + w[13];
    t1 = k[68] + w[4] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[5] =sigma1(w[3]) + sigma0(w[6]) + w[5] + w[14];
    t1 = k[69] + w[5] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[6] =sigma1(w[4]) + sigma0(w[7]) + w[6] + w[15];
    t1 = k[70] + w[6] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[7] =sigma1(w[5]) + sigma0(w[8]) + w[7] + w[0];
    t1 = k[71] + w[7] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[8] =sigma1(w[6]) + sigma0(w[9]) + w[8] + w[1];
    t1 = k[72] + w[8] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[9] =sigma1(w[7]) + sigma0(w[10]) + w[9] + w[2];
    t1 = k[73] + w[9] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[10] =sigma1(w[8]) + sigma0(w[11]) + w[10] + w[3];
    t1 = k[74] + w[10] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[11] =sigma1(w[9]) + sigma0(w[12]) + w[11] + w[4];
    t1 = k[75] + w[11] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[12] =sigma1(w[10]) + sigma0(w[13]) + w[12] + w[5];
    t1 = k[76] + w[12] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[13] =sigma1(w[11]) + sigma0(w[14]) + w[13] + w[6];
    t1 = k[77] + w[13] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[14] =sigma1(w[12]) + sigma0(w[15]) + w[14] + w[7];
    t1 = k[78] + w[14] + h + Sigma1(e) + Ch(e, f, g);
    t2 = Maj(a, b, c) + Sigma0(a);
    
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  
    w[15] =sigma1(w[13]) + sigma0(w[0]) + w[15] + w[8];
    t1 = k[79] + w[15] + h + Sigma1(e) + Ch(e, f, g);

    t2 = Maj(a, b, c) + Sigma0(a);

    h = g + iv512[7];
    g = f + iv512[6];
    f = e + iv512[5];
    e = d + t1 + iv512[4];
    d = c + iv512[3];
    c = b + iv512[2];
    b = a + iv512[1];
    a = t1 + t2 + iv512[0];
    /* Can't get rid of these because we need to find collisions
     * across H values, not just within.  Otherwise we could use
     * modular congruence.  Rats. This does mean we could normalize
     * and get rid of *one* addition, but hardly seems worth it.
     */

#if 1
#define FINALIZE(x) NUKE_THE_HIGH_BITS(x)
#else
#define FINALIZE(x) (MOSTLY_SWAP64(x)>>14)
#endif
#if 0
    H[0] = (FINALIZE(a));
    H[1] = (FINALIZE(b));
    H[2] = (FINALIZE(c));
    H[3] = (FINALIZE(d));
    H[4] = (FINALIZE(e));
    H[5] = (FINALIZE(f));
    H[6] = (FINALIZE(g));
    H[7] = (FINALIZE(h));
#else
    H[0*programCount + programIndex] = (FINALIZE(a));
    H[1*programCount + programIndex] = (FINALIZE(b));
    H[2*programCount + programIndex] = (FINALIZE(c));
    H[3*programCount + programIndex] = (FINALIZE(d));
    H[4*programCount + programIndex] = (FINALIZE(e));
    H[5*programCount + programIndex] = (FINALIZE(f));
    H[6*programCount + programIndex] = (FINALIZE(g));
    H[7*programCount + programIndex] = (FINALIZE(h));
#endif
}


export void sha512_ispc(uniform unsigned int64 data[5], uniform unsigned int64 * uniform buf, uniform int base) {
  for (uniform int i = 0; i < 8; i+= programCount) {
    sha512_block(&buf[i*8], i+programIndex, data, base);
  }
}

inline void
put_hash_in_bucket(varying unsigned int64 hash, uniform unsigned int64 * uniform hashMap, uniform unsigned int * uniform hash_counts, varying unsigned int nonce) {
  unsigned int bin = hash & 0x3ff;
  unsigned int64 nonce64 = nonce;
  /* 10:  we need 26, we had 14 b/c of momentum and we threw away 2
   * with nuke the high bits.  38 is 64-26 */
  unsigned int64 hashval = (nonce64 << 38) | (hash >> 10);
  hashMap[hash_counts[bin]] = hashval;
  hash_counts[bin]++;
}

/* This is now terribly misnamed, yo. */
export void put_32_in_buckets(uniform unsigned int64 * uniform shacache,
			      uniform unsigned int64 * uniform hashMap,
			      uniform unsigned int * uniform hash_counts,
			      uniform unsigned int nonce_start) {

  // generator
  //  for (uniform int i = 0; i < 8; i+= programCount) {
  //    sha512_block(&buf[i*8], i+programIndex, data, base);
  //  }

  for (uniform int i = 0; i < 8; i += programCount) {
    for (int j = 0; j < 8; j++) {
      put_hash_in_bucket(shacache[i*8 + j*programCount + programIndex], hashMap, hash_counts, nonce_start+(i+programIndex)*8+j);
    }
  }
}

inline
void set_or_double(uniform unsigned int * varying countbits, varying unsigned int whichbit) {
  /* Saturating unary counter with overflow bit.  
   * First set is 00 -> 01.  Second set is 01 -> 11
   * Beyond that stays 11
   */
  unsigned int whichword = whichbit/16;
  unsigned int old = countbits[whichword];
  unsigned int bitpat = 1UL << ((whichbit & 0xf)<<1);
  /* When in doubt for further optimizations, try getting rid of
   * conditionals! :-)  
   * (set 2nd bit of pair if 1st already set, 1st otherwise) */
  countbits[whichword] = old | (bitpat + (old&bitpat));
}

#define COUNTBITS_SLOTS_POWER 19
inline
void add_to_filter(uniform unsigned int *countbits, varying unsigned int64 hash) {
  varying unsigned int whichbit = (hash & ((1UL<<COUNTBITS_SLOTS_POWER)-1));
  set_or_double(countbits, whichbit);
}

#define MIN_PART_SIZE 57344
// XXX - fix the hardcode here.  We need a shared .h.
export void add_big_set_to_filter(uniform unsigned int64 * uniform buckets,
			  uniform unsigned int * uniform collisionIndices,
			  uniform unsigned int n) {
  foreach (i = 0 ... MIN_PART_SIZE) {
    add_to_filter(collisionIndices, buckets[i]);
  }
}

export void add_set_to_filter(uniform unsigned int64 * uniform buckets,
			  uniform unsigned int * uniform collisionIndices,
			  uniform unsigned int n) {
  foreach (i = 0 ... n) {
    add_to_filter(collisionIndices, buckets[i]);
  }
}

export void add_set_to_filter_shift19(uniform unsigned int64 * uniform buckets,
			  uniform unsigned int * uniform collisionIndices,
			  uniform unsigned int n) {
  foreach (i = 0 ... n) {
    add_to_filter(collisionIndices, buckets[i]>>19);
  }
}

inline
bool is_in_filter_twice(uniform unsigned int * uniform countbits, varying unsigned int64 hash) {
  unsigned int h32 = hash;
  unsigned int whichbit = (h32 & ((1UL<<COUNTBITS_SLOTS_POWER)-1));
  unsigned int cbits = countbits[whichbit>>4];
  return (cbits & (2UL<<(((whichbit&0xf)<<1))));
}

#if 1 // having some problems here
// XXX - fix the hardcode here.  We need a shared .h.
export uniform unsigned int compact_big_set_from_filter(uniform unsigned int64 * uniform buckets,
						uniform unsigned int * uniform collisionIndices) {
  unsigned int n_valid_entries = 0;
  foreach (i = 0 ... MIN_PART_SIZE) {
    varying unsigned int64 b = buckets[i];
    if (is_in_filter_twice(collisionIndices, b>>26)) {
      buckets[n_valid_entries++] = b;
    }
  }
  uniform unsigned int nve;
  nve = extract(n_valid_entries, 0);
  return nve;
}

#endif
