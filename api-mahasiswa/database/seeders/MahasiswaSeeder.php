<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Mahasiswa;

class MahasiswaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Mahasiswa::create([
            'nim' => '2441070201',
            'nama' => 'Siti Mutmainah',
            'email' => 'siti.mutmainah@example.com'
        ]);
        mahasiswa::create([
            'nim' => '244107020',
            'nama' => 'Theoladen',
            'email' => 'theoladen@example.com'
        ]);
    }
}
