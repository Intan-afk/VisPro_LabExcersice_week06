1. Perbedaan Model, View, dan ViewModel

Model (Book, Loan) hanya menyimpan data dan tidak bergantung pada widget. View (LoanCard, BorrowedBooksScreen) hanya menampilkan UI dan meneruskan aksi pengguna, sedangkan ViewModel (LibraryViewModel) menyimpan state, menjalankan aturan peminjaman, dan memberi tahu View.

2. Meminjam buku yang sudah punya pinjaman aktif

Peminjaman harus ditolak. ViewModel mengecek canBorrow dan mengembalikan ActionResult.failure dengan pesan yang ditampilkan di SnackBar, tanpa menambah data pinjaman baru.

3. Kenapa denda dihitung di satu tempat

Supaya hasilnya konsisten di semua layar dan tidak ada rumus yang berbeda-beda di tiap widget. Kalau aturan berubah, cukup diperbaiki di satu tempat (FineCalculator), dan pengujiannya juga cukup di situ.

4. Overdue vs Missing

Overdue berarti buku belum dikembalikan setelah jatuh tempo dan dendanya terus bertambah. Missing berarti keterlambatan sudah mencapai batas enam bulan, sehingga buku dianggap hilang dan peminjam ditagih harga ganti buku.

5. Jika denda mingguan berubah dari Rp5.000 ke Rp7.000

Cukup ubah satu nilai tarif di FineCalculator, tanpa menyentuh View atau ViewModel, lalu jalankan ulang test untuk memastikan hasilnya sesuai. Karena tidak ada angka denda yang ditulis langsung di widget, tampilan ikut berubah otomatis.