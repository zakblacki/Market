<?php
/**
 * File name: 2020_06_13_190949_update_v150.php
 * Last modified: 2020.06.13 at 20:09:49
 * Author: SmarterVision - https://codecanyon.net/user/smartervision
 * Copyright (c) 2020
 *
 */

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class UpdateV150 extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!\Doctrine\DBAL\Types\Type::hasType('double')) {
            \Doctrine\DBAL\Types\Type::addType('double', \Doctrine\DBAL\Types\FloatType::class);
            \Doctrine\DBAL\Types\Type::addType('tinyinteger', \Doctrine\DBAL\Types\SmallIntType::class);
        }

        if (Schema::hasTable('markets')) {
            Schema::table('markets', function (Blueprint $table) {
                $table->text('description')->nullable()->default('')->change();
            });
        }

        if (Schema::hasTable('orders')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->text('hint')->nullable()->default('')->change();
            });
        }

        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                $table->string('unit', 127)->nullable()->default('')->change();
                $table->text('description')->nullable()->default('')->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        //
    }
}
