import java.awt.Dimension;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;

import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.io.IOException;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentFragment;
import org.w3c.dom.DocumentType;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Text;

import org.apache.xerces.parsers.DOMParser;
import org.apache.xml.serialize.XMLSerializer;
import org.apache.xml.serialize.OutputFormat;

/**
 * Convert matrix expressions written in a subset of MathML to XML.
 * Code for using DOM reader and writer taken from Apache Software
 * Foundation's DOMWriter.java sample.
 *
 * @version $Id: MLtoSVG.java,v 1.10 2001/08/03 09:45:00 jdeisenberg Exp $
 */
public class MLtoSVG {

    //
    // Constants
    //


    /** Default parser name. */
    private static final String
	    DEFAULT_PARSER_NAME = "org.apache.xerces.parsers.DOMParser";
		
	private static final int LINE_HEIGHT = 24;
	private static final int FONT_HEIGHT = 14;
	private static final int SUBSCRIPT_HEIGHT = 12;
	private static final int EXTRA_HEIGHT = 10;
	private static final int X_SPACING = 2;

	private static final int BATIK_PAD = 10;
    //
    // Data
    //

	/** The "before" document */
	protected Document mlDocument;
	
	/** The "after" document */
	protected Document svgDocument;
	
	/** Permanent pointer to SVG document's root element */
	protected Element svgRoot;

    //
    // Constructors
    //

    /** Default constructor. */
    public MLtoSVG( ) {
     } // <init>(void)


    /** Read the input document and construct a document tree. */
    public void readDocument( String uri ) {
		ParserErrorHandler errHandler = new ParserErrorHandler();
		mlDocument = null;
        try {
           DOMParser parser = new org.apache.xerces.parsers.DOMParser();
			parser.setErrorHandler( errHandler );
			parser.parse( uri );
            mlDocument = parser.getDocument();
        } catch ( Exception e ) {
           e.printStackTrace(System.err);
        }
    } // readDocument(String)

	/**
	 * Generate the SVG for the matrix starting at given <mtable>
	 * Returns the total width of the matrix.
	 */
	public int generateMatrix( Node mtableNode, int currX, int totalHeight )
	{
		double		y;
		int			x = 0;
		NodeList	rowList;		// list of all <mtr> elements
		NodeList	cellList;		// list of all <mtd> elements
		Element		newElement;		// a catch-all "new element"
		Element		gElement;		// a created <g> element
		Element		startColumn;	// marks beginning of a column
		Element		textElement;	// a created <text> element
		
		int			nRows;			// number of rows in table
		int			nCells;			// number of cells per row
		int			i;				// ubiquitous loop counter
		int			row, col;		// more counter variables
		int			colWidth;		// maximum width of a column
		
		Dimension	textInfo;		// holds text width and height

		rowList = ((Element) mtableNode).getElementsByTagName("mtr");
		nRows = rowList.getLength();
		
		/* Check to see that all rows have the same number of cells */
		cellList = ((Element) rowList.item(0)).getElementsByTagName("mtd");
		nCells = cellList.getLength();
		for (i = 1; i < nRows; i++)
		{
			cellList = ((Element) rowList.item(i)).getElementsByTagName("mtd");
			if (cellList.getLength() != nCells)
			{
				System.err.println("All rows must have " + nCells + " cells ");
				System.exit(1);
			}
		}
		
		y = (totalHeight - nRows * LINE_HEIGHT) / 2.0;
		newElement = svgDocument.createElement("g");
		newElement.setAttribute("transform",
			"translate(" + (currX+BATIK_PAD) + ", " + (y+BATIK_PAD) + ")" );
		newElement.setAttribute("font-family", "sans-serif");
		newElement.setAttribute("font-size",
			Integer.toString(FONT_HEIGHT));
		
		gElement = (Element) svgRoot.appendChild( newElement );
		
		newElement = svgDocument.createElement("path");
		newElement.setAttribute("d",
			"M3 0h-3v" + (nRows*LINE_HEIGHT) +
				"h3");
		newElement.setAttribute("fill", "none");
		newElement.setAttribute("stroke", "black");
		
		/* The next "nCells" siblings of this element
		   will be the first column of the matrix */ 
		startColumn = (Element) gElement.appendChild( newElement );

		/* Now get all the <mtd> cells in order */
		cellList = ((Element) mtableNode).getElementsByTagName("mtd");

		x = X_SPACING;

		textElement = null;

		for (col = 0; col < nCells; col++)
		{
			Node	currNode;
			String	colorStr;

			colWidth = 0;
			for (row = 0; row < nRows; row++)
			{
				currNode = cellList.item( row * nCells + col );
				newElement = svgDocument.createElement("text");

				textInfo = constructTextNode( newElement, currNode,
					FONT_HEIGHT );
				textElement = (Element) gElement.appendChild( newElement );
				textElement.setAttribute("y",
					Integer.toString( row * LINE_HEIGHT + textInfo.height ) );
				textElement.setAttribute("text-anchor", "middle");
				textElement.setAttribute("font-size",
					Integer.toString(FONT_HEIGHT));
					
				colorStr = ((Element) currNode).getAttribute("color");
				if (!colorStr.equals(""))
				{
					textElement.setAttribute("fill", colorStr);
				}
				if (textInfo.width > colWidth)
				{
					colWidth = textInfo.width;
				}
			}

			/* go back and put in the "x" coordinates */
			startColumn = (Element) startColumn.getNextSibling();
			for (row = 0; row < nRows; row++)
			{
				startColumn.setAttribute("x",
					Double.toString( x + colWidth/2.0 ) );
				startColumn = (Element) startColumn.getNextSibling();
			}
			x += colWidth + X_SPACING;
			startColumn = textElement;

		}
		
		x += X_SPACING;
		/* the closing bracket */
		newElement = svgDocument.createElement("path");
		newElement.setAttribute("d",
			"M" + (x-3) + " 0h3v" + (nRows*LINE_HEIGHT) +
			"h-3");
		newElement.setAttribute("fill", "none");
		newElement.setAttribute("stroke", "black");
		startColumn = (Element) gElement.appendChild( newElement );

		return x + 2*X_SPACING;
	}

	/**
	 * Generate the SVG for an operator starting at given <mo> node
	 * Returns the total width of the operator.
	 */
	public int generateOperator( Node moNode, int currX, int totalHeight )
	{
		double		y;
		int			fontsize;
		Element		newElement, textElement;
		Dimension	textInfo;

		currX += X_SPACING;
		y = (totalHeight) / 2.0;
		
		fontsize = FONT_HEIGHT;
		if (moNode.getFirstChild().getNodeType() == Node.TEXT_NODE)
		{
			/*(rx ry x-axis-rotation large-arc-flag sweep-flag x y) */
			String str = moNode.getFirstChild().getNodeValue();
			if (str.equals( "(" ))
			{
				newElement = svgDocument.createElement("path");
				newElement.setAttribute( "d",
					"M" + (currX+12) + " 8 a12 " + y + " 0 0 0 " +
						"0" + " " + (totalHeight-EXTRA_HEIGHT - 8) );
				newElement.setAttribute( "fill", "none");
				newElement.setAttribute( "stroke", "black" );
				svgRoot.appendChild( newElement );
				return 16 + X_SPACING;
			}
			else if (str.equals( ")" ))
			{
				newElement = svgDocument.createElement("path");
				newElement.setAttribute( "d",
					"M" + currX + " 8 a12 " + y + " 0 0 1 " +
						"0" + " " + (totalHeight-EXTRA_HEIGHT - 8) );
				newElement.setAttribute( "fill", "none");
				newElement.setAttribute( "stroke", "black" );
				svgRoot.appendChild( newElement );
				return 10 + X_SPACING;
			}
		}

		newElement = svgDocument.createElement("text");
		textInfo = constructTextNode( newElement, moNode, fontsize );
		
		textElement = (Element) svgRoot.appendChild( newElement );
		if (fontsize != FONT_HEIGHT)
		{
			y = 0;
			textElement.setAttribute("stroke-width",
				Double.toString( (FONT_HEIGHT * 1.0 / fontsize )) );
		}
		textElement.setAttribute("transform",
			"translate(" + (currX+BATIK_PAD) + ", " +
			(y+BATIK_PAD+textInfo.height/2.0) + ")" );
		textElement.setAttribute("font-size",
			Integer.toString(fontsize));
		
		return textInfo.width + 2 * X_SPACING;
	}

	/**
	 * Attach text node to parent; constructed from source at given font size
	 *
	 * destNode is the destination node of the text in the output document
	 * parentNode is the node of the source document that contains the text to be added
	 * size is the font size to start with
	 *
	 * returns the total text width and the maximum text ascent
	 */
	public Dimension constructTextNode( Node destNode, Node parentNode, int size )
	{
		NodeList	children = parentNode.getChildNodes();
		Node		currNode;
		int			i;
		Dimension	d = new Dimension(0, 0);
		Dimension	subDim;

		for (i=0; i < children.getLength(); i++ )
		{
			subDim = new Dimension(0,0);
			currNode = children.item(i);
			if (currNode.getNodeName().equals("#text"))
			{
				Text	textNode;
				String	value = currNode.getNodeValue();
				subDim = stringInfo( value, size );
				textNode = svgDocument.createTextNode( value );
				destNode.appendChild( textNode );
			}
			else if (currNode.getNodeName().equals("msub"))
			{
				Element	newElement;
				newElement = svgDocument.createElement("tspan");
				newElement.setAttribute( "baseline-shift",
					"sub");
				newElement.setAttribute("font-size",
					Integer.toString(SUBSCRIPT_HEIGHT));
				newElement = (Element) destNode.appendChild( newElement );
				subDim = constructTextNode( newElement, currNode,
					SUBSCRIPT_HEIGHT );				
			}
			else if (currNode.getNodeType() == Node.ELEMENT_NODE)
			{
				subDim = constructTextNode( destNode, currNode, size );
			}
			d.width += subDim.width;
			if (subDim.height > d.height)
			{
				d.height = subDim.height;
			}
		}
		return d;
	}
	
	public Dimension stringInfo( String str, int fontSize )
	{
		BufferedImage buffer = new BufferedImage(
			100, 100, BufferedImage.TYPE_INT_RGB);
		Graphics g = buffer.getGraphics();
		Font f = new Font("SansSerif", Font.PLAIN, fontSize);
		g.setFont( f );
		FontMetrics fm = g.getFontMetrics();

		return new Dimension( fm.stringWidth( str ), fm.getAscent() );
	}
		
	/**
	 * Process a MathML document and produce an SVG version of same.
	 * To save time in writing the code, we presume that there's only
	 * one <mrow> element in the MathML document.
	 */
	public void processDocument( )
	{
		svgDocument = null;
		
		/* anything to do? */
		if (mlDocument == null)
		{
			return;
		}

		/* Create the output document */
		DOMImplementation dImplement = mlDocument.getImplementation();
		DocumentType dType = dImplement.createDocumentType(
			"svg",
			"-//W3C//DTD SVG 20001102//EN",
			"http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd"
		);
		svgDocument = dImplement.createDocument( null, "svg", dType);
		svgRoot = (Element) svgDocument.getDocumentElement();
		Element		mrowElement;	// store <mrow> element for ease of access
		NodeList	matrices;		// list of all <mtable> elements
		NodeList	rows;			// list of all <mtr> elements
		NodeList	nodes;			// immediate children of <mrow>
		int			i;				// ubiquitous counter
		
		/* current x  position while creating matrices */
		int currX = 0;

		/* maximum number of rows in any one matrix */
		int maxRows = 0;
		int totalHeight;

		/* Find the first <mrow> node */
		nodes = mlDocument.getElementsByTagName("mrow");
		mrowElement = (Element) nodes.item(0);
		
		/* Find the maximum number of rows among all the matrices */
		matrices = mrowElement.getElementsByTagName("mtable");		
		for (i = 0; i < matrices.getLength(); i++)
		{
			rows = ((Element) matrices.item(i)).getElementsByTagName("mtr");
			if (rows.getLength() > maxRows)
			{
				maxRows = rows.getLength();
			}
		}
		
		/* Calculate total height */
		totalHeight = maxRows * LINE_HEIGHT + EXTRA_HEIGHT;
		/* Now create the SVG for the matrices and operators */
		nodes = mrowElement.getChildNodes();
		for (i=0; i < nodes.getLength(); i++)
		{
			if (nodes.item(i).getNodeName().equals("mtable"))
			{
				currX += generateMatrix( nodes.item(i), currX, totalHeight );
			}
			else if (nodes.item(i).getNodeName().equals("mo"))
			{
				currX += generateOperator( nodes.item(i), currX, totalHeight );
			}
		}
		
		currX += 2 * X_SPACING;	// put some padding at the right

		svgRoot.setAttribute("width", Integer.toString( currX + 20 ));
		svgRoot.setAttribute("height", Integer.toString( totalHeight + 20 ) );
		svgRoot.setAttribute("viewBox",
			"0 0 " + (currX+20) + " " + (totalHeight+20));

	}

    public void printDocument( ) {
		
		if (svgDocument == null)
		{
			return;
		}
        PrintWriter out = null;
		try{
			out =
			new PrintWriter(new OutputStreamWriter(System.out, "UTF-8"));
		}
		catch (Exception e)
		{
			System.err.println("Error creating output stream");
			System.err.println(e.getMessage());
			System.exit(1);
		}
		OutputFormat oFormat = new OutputFormat( "xml", "UTF-8", true );
		XMLSerializer serial = new XMLSerializer( out, oFormat );
		try
		{
			serial.serialize( svgDocument );
		}
		catch (java.io.IOException e)
		{
			System.err.println(e.getMessage());
		}
	}

    //
    // Main
    //

    /** Main program entry point. */
    public static void main(String argv[]) {

        // is there anything to do?
        if ( argv.length == 0 ) {
            System.err.println("usage: java MLtoSVG filename");
            System.exit(1);
        }

        // vars
		MLtoSVG converter = null;

		converter = new MLtoSVG();
		
		converter.readDocument( argv[0] );
		System.err.println("Document read.");
		converter.processDocument( );
		System.err.println("Document processed.");
		converter.printDocument( );
		System.err.println("Document printed");

    } // main(String[])

}
