FasdUAS 1.101.10   ��   ��    k             l     ��  ��    7 1 Runs an R script and returns errors if any occur     � 	 	 b   R u n s   a n   R   s c r i p t   a n d   r e t u r n s   e r r o r s   i f   a n y   o c c u r   
  
 i         I      �� ���� &0 runrscripthandler runRScriptHandler   ��  o      ���� 	0 input  ��  ��    k     P       r         n        1    ��
�� 
txdl  1     ��
�� 
ascr  o      ���� 0 	olddelims 	oldDelims      r        m       �    |  n         1    
��
�� 
txdl  1    ��
�� 
ascr       l   ��������  ��  ��      ! " ! l   �� # $��   # < 6 rscript path is the path to your Rscript installation    $ � % % l   r s c r i p t   p a t h   i s   t h e   p a t h   t o   y o u r   R s c r i p t   i n s t a l l a t i o n "  & ' & l   �� ( )��   ( C = scriptPath is the pathe to the R script that you want to run    ) � * * z   s c r i p t P a t h   i s   t h e   p a t h e   t o   t h e   R   s c r i p t   t h a t   y o u   w a n t   t o   r u n '  + , + l   �� - .��   - 9 3 params is the params string to pass to the script	    . � / / f   p a r a m s   i s   t h e   p a r a m s   s t r i n g   t o   p a s s   t o   t h e   s c r i p t 	 ,  0 1 0 l   ��������  ��  ��   1  2 3 2 l   �� 4 5��   4 "  Extract parameters from VBA    5 � 6 6 8   E x t r a c t   p a r a m e t e r s   f r o m   V B A 3  7 8 7 r     9 : 9 n     ; < ; 4    �� =
�� 
citm = m    ����  < o    ���� 	0 input   : o      ���� 0 rscriptpath rscriptPath 8  > ? > r     @ A @ n     B C B 4    �� D
�� 
citm D m    ����  C o    ���� 	0 input   A o      ���� 0 
scriptpath 
scriptPath ?  E F E r      G H G n     I J I 4    �� K
�� 
citm K m    ����  J o    ���� 	0 input   H o      ���� 
0 params   F  L M L l  ! !��������  ��  ��   M  N O N r   ! & P Q P o   ! "���� 0 	olddelims 	oldDelims Q n      R S R 1   # %��
�� 
txdl S 1   " #��
�� 
ascr O  T U T l  ' '��������  ��  ��   U  V W V l  ' '�� X Y��   X 6 0 Construct the shell command (stderr redirected)    Y � Z Z `   C o n s t r u c t   t h e   s h e l l   c o m m a n d   ( s t d e r r   r e d i r e c t e d ) W  [ \ [ r   ' 4 ] ^ ] b   ' 2 _ ` _ b   ' 0 a b a b   ' . c d c b   ' , e f e b   ' * g h g o   ' (���� 0 rscriptpath rscriptPath h m   ( ) i i � j j    f o   * +���� 0 
scriptpath 
scriptPath d m   , - k k � l l    b o   . /���� 
0 params   ` m   0 1 m m � n n 
   2 > & 1 ^ o      ���� 0 shellcommand shellCommand \  o p o l  5 5��������  ��  ��   p  q r q Q   5 M s t u s k   8 ? v v  w x w l  8 8�� y z��   y ) # Run the command and capture output    z � { { F   R u n   t h e   c o m m a n d   a n d   c a p t u r e   o u t p u t x  |�� | r   8 ? } ~ } I  8 =�� ��
�� .sysoexecTEXT���     TEXT  o   8 9���� 0 shellcommand shellCommand��   ~ o      ���� 
0 output  ��   t R      �� ���
�� .ascrerr ****      � **** � o      ���� 0 errormessage errorMessage��   u k   G M � �  � � � l  G G�� � ���   � ' ! Return the error message instead    � � � � B   R e t u r n   t h e   e r r o r   m e s s a g e   i n s t e a d �  ��� � L   G M � � b   G L � � � b   G J � � � m   G H � � � � � : E R R O R   c a u g h t   i n   a p p l e s c r i p t :   � o   H I���� 0 errormessage errorMessage � m   J K � � � � � 
 E R R O R��   r  � � � l  N N��������  ��  ��   �  ��� � L   N P � � o   N O���� 
0 output  ��     ��� � l     ��������  ��  ��  ��       �� � ���   � ���� &0 runrscripthandler runRScriptHandler � �� ���� � ����� &0 runrscripthandler runRScriptHandler�� �� ���  �  ���� 	0 input  ��   � ������������������ 	0 input  �� 0 	olddelims 	oldDelims�� 0 rscriptpath rscriptPath�� 0 
scriptpath 
scriptPath�� 
0 params  �� 0 shellcommand shellCommand�� 
0 output  �� 0 errormessage errorMessage � ���� �� i k m������ � �
�� 
ascr
�� 
txdl
�� 
citm
�� .sysoexecTEXT���     TEXT�� 0 errormessage errorMessage��  �� Q��,E�O���,FO��k/E�O��l/E�O��m/E�O���,FO��%�%�%�%�%E�O �j E�W X  	�%�%O�ascr  ��ޭ