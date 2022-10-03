/*
 * Application: one-time initialization at app startup
 *
 * This file is part of Easy Token
 * Copyright (c) 2014, Kevin Cernekee <cernekee@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

package app.easytoken;

public class Application extends android.app.Application {

	@Override
	public void onCreate() {
		super.onCreate();
		System.loadLibrary("stoken");
		TokenInfo.init(getApplicationContext());
		TokencodeWidgetService.kick(getApplicationContext());
	}
}
