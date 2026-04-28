// sine 0..90 度テーブル。値は固定小数点で、255 がほぼ 1.0。
// BYTE に収めるため、厳密な 1.0 (=256) ではなく最大値 255 に丸めている。
ARRAY BYTE SIN_TBL[91] = {
      0,   4,   9,  13,  18,  22,  27,  31,  36,  40,  44,  49,  53,
     58,  62,  66,  71,  75,  79,  83,  88,  92,  96, 100, 104, 108,
    112, 116, 120, 124, 128, 132, 136, 139, 143, 147, 150, 154, 158,
    161, 165, 168, 171, 175, 178, 181, 184, 187, 190, 193, 196, 199,
    202, 204, 207, 210, 212, 215, 217, 219, 222, 224, 226, 228, 230,
    232, 234, 236, 237, 239, 241, 242, 243, 245, 246, 247, 248, 249,
    250, 251, 252, 253, 254, 254, 255, 255, 255, 255, 255, 255, 255
};

// atan(r / 256) の 0..45 度テーブル。r は 0..256 の比率。
// ATAN2_I_FAST で、X/Y の絶対値比から基準角を求めるために使う。
ARRAY BYTE ATAN_TBL[256] = {
     0,  0,  0,  1,  1,  1,  1,  2,  2,  2,  2,  2,  3,  3,  3,  3,
     4,  4,  4,  4,  4,  5,  5,  5,  5,  6,  6,  6,  6,  6,  7,  7,
     7,  7,  8,  8,  8,  8,  8,  9,  9,  9,  9, 10, 10, 10, 10, 10,
    11, 11, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14,
    14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17,
    17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20,
    21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23,
    24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26,
    27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29,
    29, 30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31, 32, 32, 32,
    32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 34, 34, 34, 34, 34, 34,
    35, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 36, 36, 37, 37,
    37, 37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39,
    39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41,
    41, 41, 41, 42, 42, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43,
    43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 44, 45, 45, 45, 45,
    45
};


// 符号付き固定小数点同士を掛ける。小数部は 8bit、256 が 1.0。
FIXMUL_S(A, B)
VAR T;
{
    T = A .*. B;
    RETURN T ./. 256;
}


// 符号付き固定小数点同士を割る。B が 0 のときは 0 を返す。
FIXDIV_S(A, B)
VAR SA, SB, UA, UB, I, F, Q;
{
    IF (B == 0) RETURN 0;

    SA = 0;
    SB = 0;
    IF (A .<. 0) SA = 1;
    IF (B .<. 0) SB = 1;

    UA = ABS(A);
    UB = ABS(B);

    I = UA / UB;
    IF (I >= 128) {
        IF (SA != SB) RETURN -32767;
        RETURN 32767;
    }

    F = RATIO256(UA MOD UB, UB);
    Q = I * 256 + F;

    IF (SA != SB) RETURN -Q;
    RETURN Q;
}


// 整数 X に固定小数点 F を掛ける。F は 256 が 1.0。
FIXMUL_I(X, F)
VAR T;
{
    T = X .*. F;
    RETURN T ./. 256;
}


// 角度を 0..359 度の範囲に正規化する。
NORMALIZE360(A)
{
    WHILE (A .<. 0) {
        A = A + 360;
    }

    WHILE (A >= 360) {
        A = A - 360;
    }

    RETURN A;
}


// 角度 A 度の sine を返す。戻り値は符号付き固定小数点で、255 がほぼ 1.0。
SIN_F(A)
VAR X;
{
    X = NORMALIZE360(A);

    IF (X <= 90) {
        RETURN SIN_TBL[X];
    }

    IF (X <= 180) {
        RETURN SIN_TBL[180 - X];
    }

    IF (X <= 270) {
        RETURN -SIN_TBL[X - 180];
    }

    RETURN -SIN_TBL[360 - X];
}


// 角度 A 度の cosine を返す。戻り値は SIN_F と同じスケール。
COS_F(A)
{
    RETURN SIN_F(90 - A);
}


// 角度 A 度の tangent を返す。cosine が 0 に近い場合は飽和値を返す。
TAN_F(A)
VAR S, C;
{
    S = SIN_F(A);
    C = COS_F(A);

    IF (ABS(C) < 1) {
        IF (S .<. 0) RETURN -32767;
        RETURN 32767;
    }

    RETURN FIXDIV_S(S, C);
}


// 点 (X,Y) を A 度回転した後の X 座標を返す。
ROTATE_X(X, Y, A)
VAR C, S, T1, T2, T;
{
    C = COS_F(A);
    S = SIN_F(A);

    T1 = X .*. C;
    T2 = Y .*. S;
    T = T1 - T2;

    RETURN T ./. 256;
}


// 点 (X,Y) を A 度回転した後の Y 座標を返す。
ROTATE_Y(X, Y, A)
VAR C, S, T1, T2, T;
{
    C = COS_F(A);
    S = SIN_F(A);

    T1 = X .*. S;
    T2 = Y .*. C;
    T = T1 + T2;

    RETURN T ./. 256;
}


// 点 (X,Y) を中心 (CX,CY) のまわりに A 度回転し、結果を RP[0], RP[1] に入れる。
ROTATE_CENTER(RP, X, Y, CX, CY, A)
VAR RP[], DX, DY, C, S, T1, T2, T;
{
    DX = X - CX;
    DY = Y - CY;

    C = COS_F(A);
    S = SIN_F(A);

    T1 = DX .*. C;
    T2 = DY .*. S;
    T = T1 - T2;
    RP[0] = CX + (T ./. 256);

    T1 = DX .*. S;
    T2 = DY .*. C;
    T = T1 + T2;
    RP[1] = CY + (T ./. 256);
}


// 角度 ANG、速度 SPEED で移動した後の X 座標を返す。
MOVE_X(X, SPEED, ANG)
{
    RETURN X + FIXMUL_I(SPEED, COS_F(ANG));
}


// 角度 ANG、速度 SPEED で移動した後の Y 座標を返す。
MOVE_Y(Y, SPEED, ANG)
{
    RETURN Y + FIXMUL_I(SPEED, SIN_F(ANG));
}


// NUM / DEN を 0..256 の比率に変換する。ATAN2_I_FAST のテーブル参照用。
RATIO256(NUM, DEN)
VAR Q, I;
{
    IF (DEN == 0) RETURN 0;
    IF (NUM >= DEN) RETURN 256;

    Q = 0;
    I = 0;

    WHILE (I < 8) {
        NUM = NUM + NUM;
        Q = Q + Q;

        IF (NUM >= DEN) {
            NUM = NUM - DEN;
            Q = Q + 1;
        }

        I = I + 1;
    }

    RETURN Q;
}


// 高速な atan2。テーブル参照と象限補正で 0..359 度を返す。
ATAN2_I_FAST(Y, X)
VAR AX, AY, R, A;
{
    IF (X == 0) {
        IF (Y == 0) RETURN 0;
        IF (Y .<. 0) RETURN 270;
        RETURN 90;
    }

    IF (Y == 0) {
        IF (X .<. 0) RETURN 180;
        RETURN 0;
    }

    AX = ABS(X);
    AY = ABS(Y);

    IF (AX >= AY) {
        R = RATIO256(AY, AX);
        A = ATAN_TBL[R];
    } ELSE {
        R = RATIO256(AX, AY);
        A = 90 - ATAN_TBL[R];
    }

    IF (X .<. 0) {
        IF (Y .<. 0) RETURN 180 + A;
        RETURN 180 - A;
    }

    IF (Y .<. 0) RETURN 360 - A;
    RETURN A;
}


// 総当たり版 atan2。精度確認用に全角度の内積を比較して 0..359 度を返す。
ATAN2_I(Y, X)
VAR A, BEST_A, DX, DY, SCORE, BEST_SCORE;
{
    IF (X == 0) {
        IF (Y == 0) RETURN 0;
    }

    BEST_A = 0;
    BEST_SCORE = -32767;

    A = 0;
    WHILE (A < 360) {
        DX = COS_F(A);
        DY = SIN_F(A);

        SCORE = (X .*. DX) + (Y .*. DY);

        IF (SCORE .>. BEST_SCORE) {
            BEST_SCORE = SCORE;
            BEST_A = A;
        }

        A = A + 1;
    }

    RETURN BEST_A;
}


// 正の整数を 10 進数で表示する。
PRINTINT(X)
VAR Y, D, Z, N;
{
    Y = X;
    D = 10000;
    Z = 0;

    IF (Y == 0) {
        PRINT("0");
        RETURN;
    }

    WHILE (D > 0) {
        N = 0;

        WHILE (Y >= D) {
            Y = Y - D;
            N = N + 1;
        }

        IF (N != 0 OR Z != 0) {
            PRINT(N);
            Z = 1;
        }

        D = D / 10;
    }
}


// 符号付き整数を 10 進数で表示する。
PRINTS(X)
VAR Y;
{
    Y = X;

    IF (Y .<. 0) {
        PRINT("-");
        Y = -Y;
    }

    PRINTINT(Y);
}


// 0..999 の数値を 3 桁ゼロ埋めで表示する。固定小数点の小数部表示用。
PRINTF3(X)
{
    IF (X < 100) PRINT("0");
    IF (X < 10) PRINT("0");
    PRINTINT(X);
}


// 符号付き固定小数点を 10 進小数で表示する。小数部は 3 桁、256 が 1.0。
PRINTFIX(X)
VAR Y, I, R, F;
{
    Y = X;

    IF (Y .<. 0) {
        PRINT("-");
        Y = -Y;
    }

    I = Y / 256;
    R = Y MOD 256;
    F = R * 4 - ((R * 24 + 255) / 256);

    PRINTINT(I);
    PRINT(".");
    PRINTF3(F);
}
