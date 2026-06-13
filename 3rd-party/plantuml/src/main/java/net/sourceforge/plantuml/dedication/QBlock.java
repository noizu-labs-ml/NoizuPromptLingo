/* ========================================================================
 * PlantUML : a free UML diagram generator
 * ========================================================================
 *
 * (C) Copyright 2009-2024, Arnaud Roques
 *
 * Project Info:  https://plantuml.com
 * 
 * If you like this project or if you find it useful, you can support us at:
 * 
 * https://plantuml.com/patreon (only 1$ per month!)
 * https://plantuml.com/paypal
 * 
 * This file is part of PlantUML.
 *
 * PlantUML is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * PlantUML distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 * License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
 * USA.
 *
 *
 * Original Author:  Arnaud Roques
 * 
 *
 */
package net.sourceforge.plantuml.dedication;

import java.math.BigInteger;

public class QBlock {

	private final BigInteger big;

	public static QBlock fromBuffer(final byte[] buffer) {
		final byte[] block = new byte[buffer.length + 1];
		System.arraycopy(buffer, 0, block, 1, buffer.length);
		final BigInteger big = new BigInteger(block);
		return new QBlock(big);
	}

	public QBlock(BigInteger number) {
		this.big = number;
	}

	public QBlock change(BigInteger E, BigInteger N) {
		final BigInteger changed = big.modPow(E, N);
		return new QBlock(changed);
	}

	public byte[] getData512() {
		final byte[] nb = big.toByteArray();
		if (nb.length == 512)
			return nb;

		final byte[] result = new byte[512];
		if (nb.length < 512)
			System.arraycopy(nb, 0, result, 512 - nb.length, nb.length);
		else
			System.arraycopy(nb, nb.length - 512, result, 0, 512);

		return result;
	}

	public byte[] getDataRaw() {
		return big.toByteArray();
	}

	@Override
	public String toString() {
		return big.toByteArray().length + " " + big.toString(36);
	}
}
